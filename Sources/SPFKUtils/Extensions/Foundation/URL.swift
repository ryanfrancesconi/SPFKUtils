// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/SPFKUtils

import Foundation
import UniformTypeIdentifiers

fileprivate let allocatedSizeResourceKeys: Set<URLResourceKey> = [
    .isRegularFileKey,
    .fileAllocatedSizeKey,
    .totalFileAllocatedSizeKey,
]

extension URL {
    public var exists: Bool {
        FileManager.default.fileExists(atPath: path)
    }

    public var isReadable: Bool {
        FileManager.default.isReadableFile(atPath: path) &&
            !FileManager.default.isInTrash(self)
    }

    public func delete() throws {
        try FileManager.default.removeItem(at: self)
    }

    public func createDirectory() throws {
        guard !exists else { return }
        try FileManager.default.createDirectory(at: self, withIntermediateDirectories: true)
    }

    public var isValidForNetworkLookup: Bool {
        let string = absoluteString
        let regEx = "((?:http|https)://)?(?:www\\.)?[\\w\\d\\-_]+\\.\\w{2,3}(\\.\\w{2})?(/(?<=/)(?:[\\w\\d\\-./_]+)?)?"
        let predicate = NSPredicate(format: "SELF MATCHES %@", argumentArray: [regEx])
        return predicate.evaluate(with: string)
    }

    /// Calculate the allocated size of a directory and all its contents on the volume.
    ///
    /// As there's no simple way to get this information from the file system the method
    /// has to crawl the entire hierarchy, accumulating the overall sum on the way.
    /// The resulting value is roughly equivalent with the amount of bytes
    /// that would become available on the volume if the directory would be deleted.
    ///
    /// - note: There are a couple of oddities that are not taken into account (like symbolic links, meta data of
    /// directories, hard links, ...).
    public var allocatedSizeOfDirectory: UInt64? {
        guard isDirectory else { return nil }

        // The error handler simply stores the error and stops traversal
        var enumeratorError: Error?
        func errorHandler(_: URL, error: Error) -> Bool {
            enumeratorError = error
            return false
        }

        // We have to enumerate all directory contents, including subdirectories.
        let enumerator = FileManager.default.enumerator(at: self,
                                                        includingPropertiesForKeys: Array(allocatedSizeResourceKeys),
                                                        options: [],
                                                        errorHandler: errorHandler)!

        // We'll sum up content size here:
        var accumulatedSize: UInt64 = 0

        // Perform the traversal.
        for item in enumerator {
            // Bail out on errors from the errorHandler.
            if enumeratorError != nil { return nil }

            // Add up individual file sizes.
            if let contentItemURL = item as? URL, let size = contentItemURL.regularFileAllocatedSize {
                accumulatedSize += size
            }
        }

        return accumulatedSize
    }

    public var regularFileAllocatedSize: UInt64? {
        guard let resourceValues = try? resourceValues(forKeys: allocatedSizeResourceKeys) else { return nil }

        // We only look at regular files.
        guard resourceValues.isRegularFile == true else { return 0 }

        // To get the file's size we first try the most comprehensive value in terms of what
        // the file may use on disk. This includes metadata, compression (on file system
        // level) and block size.
        // In case totalFileAllocatedSize is unavailable we use the fallback value (excluding
        // meta data and compression) This value should always be available.
        return UInt64(resourceValues.totalFileAllocatedSize ?? resourceValues.fileAllocatedSize ?? 0)
    }

    public var fileSize: Int? {
        guard let value = try? resourceValues(forKeys: [.fileSizeKey]) else { return nil }
        return value.fileSize
    }

    public var mimeType: String {
        let genericType = "application/octet-stream"

        guard let type = UTType(filenameExtension: pathExtension),
              let mimetype = type.preferredMIMEType else {
            // this isn't coming through.
            if pathExtension == "caf" {
                return "audio/x-caf"
            }

            return genericType
        }
        return mimetype
    }

    public var utType: UTType? {
        try? resourceValues(forKeys: [.contentTypeKey]).contentType
    }

    public var documentKind: String? {
        if #available(macOS 11, *) {
            guard let value = try? resourceValues(forKeys: [.contentTypeKey]) else { return nil }
            return value.contentType?.localizedDescription

        } else {
            guard let value = try? resourceValues(forKeys: [.localizedTypeDescriptionKey]) else { return nil }
            return value.localizedTypeDescription
        }
    }

    public var creationDate: Date? {
        guard let value = try? resourceValues(forKeys: [.creationDateKey]) else { return nil }
        return value.creationDate
    }

    public var modificationDate: Date? {
        guard let value = try? resourceValues(forKeys: [.contentModificationDateKey]) else { return nil }
        return value.contentModificationDate
    }

    public var lastOpened: Date? {
        let itemRef = MDItemCreateWithURL(nil, self as CFURL)
        return MDItemCopyAttribute(itemRef, kMDItemLastUsedDate) as? Date
    }

    public var isDirectory: Bool {
        guard let value = try? resourceValues(forKeys: [.isDirectoryKey]) else { return false }
        return value.isDirectory == true
    }

    public var isPackage: Bool {
        guard let value = try? resourceValues(forKeys: [.isPackageKey]) else { return false }
        return value.isPackage == true
    }

    public var isDirectoryOrPackage: Bool {
        isDirectory || isPackage
    }

    public var isAlias: Bool {
        guard let value = try? resourceValues(forKeys: [.isAliasFileKey, .isSymbolicLinkKey]) else { return false }
        return value.isAliasFile == true
    }

    public var isHidden: Bool {
        guard !lastPathComponent.hasPrefix(".") else { return true }

        guard let value = try? resourceValues(forKeys: [.isHiddenKey]) else { return false }
        return value.isHidden == true
    }

    public var isRemote: Bool {
        guard let scheme = scheme?.lowercased() else { return false }
        return scheme.hasPrefix("http")
    }

    public func resolveAlias() -> URL? {
        if let symlink = resolveSymbolicLink() {
            return symlink
        }

        do {
            let data = try NSURL.bookmarkData(withContentsOf: self)
            if let rv = NSURL.resourceValues(forKeys: [.pathKey], fromBookmarkData: data) {
                if let urlString = rv[URLResourceKey.pathKey] as? String {
                    return URL(fileURLWithPath: urlString)
                }
            }
        } catch {}

        return nil
    }

    public func resolveSymbolicLink() -> URL? {
        if let symPath = try? FileManager.default.destinationOfSymbolicLink(atPath: path) {
            return URL(fileURLWithPath: symPath, relativeTo: self)
        }

        return nil
    }

    /// Return `true` if this URL contains a subdirectory or child path
    /// - Parameter childPath: the path to check
    /// - Returns: `true` or `false`
    public func contains(path childPath: String) -> Bool {
        let path = isFileURL ? self.path : absoluteString

        return path.contains(childPath) || path == childPath
    }

    public init(fileURLWithPathResolvingHome path: String) {
        var path = path
        if path.hasPrefix("~") {
            path = path.replacingOccurrences(of: "~", with: NSHomeDirectory())
        }
        self.init(fileURLWithPath: path)
    }

    public init?(fileOrNetworkURLWithPath path: String) {
        if path.lowercased().hasPrefix("http") {
            self.init(string: path)
        } else {
            self.init(fileURLWithPath: path)
        }
    }
}

extension URL {
    /// Use as sort comparator to sort URLs alphabetically by file name.
    /// Uses localized case-insensitive comparison.
    public func sortCompareFileName(_ other: URL) -> Bool {
        let lhs = lastPathComponent
        let rhs = other.lastPathComponent
        let result = lhs.localizedCaseInsensitiveCompare(rhs)
        return result == .orderedAscending
    }
}

extension Array where Element == URL {
    /// Returns URLs sorted by file name (lastPathComponent) alphabetically.
    /// Uses localized case-insensitive comparison.
    public func sortedByFileName() -> [URL] {
        sorted(by: { $0.sortCompareFileName($1) })
    }
}

// MARK: Bookmark Convenience

extension URL {
    public func toBookmarkString(options: URL.BookmarkCreationOptions = [.withSecurityScope]) -> String? {
        guard exists else { return nil }
        return try? bookmarkData(options: options).base64EncodedString()
    }

    public init?(base64EncodedBookmarkString string: String, options: BookmarkResolutionOptions = .withSecurityScope) {
        guard let data = Data(base64Encoded: string) else {
            Log.error("Failed to resolve data string")
            return nil
        }

        var stale = false

        do {
            try self.init(
                resolvingBookmarkData: data,
                options: options,
                relativeTo: nil,
                bookmarkDataIsStale: &stale
            )

        } catch {
            // Log.error("resolvingBookmarkData", error, "stale: \(stale)")
            return nil
        }
    }

    public init?(fileURLWithPath path: String,
                 base64EncodedBookmarkString: String? = nil,
                 options: BookmarkResolutionOptions = .withSecurityScope) {
        if FileManager.default.fileExists(atPath: path) {
            self.init(fileURLWithPath: path)

        } else if let base64EncodedBookmarkString = base64EncodedBookmarkString,
                  let url = URL(base64EncodedBookmarkString: base64EncodedBookmarkString, options: options),
                  url.exists {
            self = url

        } else {
            return nil
        }
    }
}

extension URL {
    public var isEmpty: Bool {
        guard isDirectoryOrPackage else { return false }

        return directoryContents?.isEmpty == true
    }

    /// FileManager convenience: [.skipsSubdirectoryDescendants, .skipsHiddenFiles]
    /// - Parameter url: The directory to list files from
    /// - Returns: a shallow (non-recursive) URL array of visible files or nil if unable
    /// to read the directory
    public var directoryContents: [URL]? {
        try? listDirectory()
    }

    /// FileManager convenience: [.skipsSubdirectoryDescendants, .skipsHiddenFiles]
    /// - Parameter url: The directory to list files from
    /// - Returns: a shallow (non-recursive) URL array of visible files or nil if unable
    /// to read the directory
    public func listDirectory(options mask: FileManager.DirectoryEnumerationOptions? = nil) throws -> [URL] {
        guard exists else {
            throw NSError(description: "\(self.path) doesn't exist")
        }

        guard isDirectoryOrPackage else {
            throw NSError(description: "\(self.path) isn't a directory")
        }

        let resourceKeys: [URLResourceKey] = [.creationDateKey, .isDirectoryKey]

        let mask = mask ?? [.skipsSubdirectoryDescendants, .skipsHiddenFiles]

        return try FileManager.default.contentsOfDirectory(
            at: self,
            includingPropertiesForKeys: resourceKeys,
            options: mask
        ).sorted {
            $0.lastPathComponent.standardCompare(with: $1.lastPathComponent, ascending: true)
        }
    }

    public var hiddenFiles: [URL]? {
        guard exists, isDirectoryOrPackage else { return nil }

        let resourceKeys: [URLResourceKey] = [.creationDateKey, .isDirectoryKey]

        guard let files = try? FileManager.default.contentsOfDirectory(
            at: self,
            includingPropertiesForKeys: resourceKeys,
            options: [.skipsSubdirectoryDescendants]
        ) else {
            return nil
        }

        return files.filter {
            $0.isHidden
        }
    }

    public func appendingBackwardsCompatible(queryItems: [URLQueryItem]) -> URL? {
        if #available(macOS 13.0, *) {
            return self.appending(queryItems: queryItems)

        } else {
            var urlString = absoluteString

            if urlString.last != "?" {
                urlString += "?"
            }

            urlString += Self.queryString(items: queryItems)

            return URL(string: urlString)
        }
    }

    public static func queryString(items: [URLQueryItem]) -> String {
        items.compactMap {
            "\($0.name)=\($0.value ?? "")"
        }.joined(separator: "&")
    }
}
