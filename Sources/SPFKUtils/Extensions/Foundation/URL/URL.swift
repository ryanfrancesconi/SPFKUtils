// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/SPFKUtils

import Foundation

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

    public var isRemote: Bool {
        scheme?.lowercased().hasPrefix("http") == true
    }

    public func resolveAlias() -> URL? {
        if let symlink = resolveSymbolicLink() {
            return symlink
        }

        guard let data = try? NSURL.bookmarkData(withContentsOf: self) else {
            return nil
        }

        guard let values = NSURL.resourceValues(forKeys: [.pathKey], fromBookmarkData: data) else {
            return nil
        }

        guard let urlString = values[URLResourceKey.pathKey] as? String else {
            return nil
        }

        return URL(fileURLWithPath: urlString)
    }

    public func resolveSymbolicLink() -> URL? {
        guard let symPath = try? FileManager.default.destinationOfSymbolicLink(atPath: path) else {
            return nil
        }

        return URL(fileURLWithPath: symPath, relativeTo: self)
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

extension Array where Element == URL {
    /// Returns URLs sorted by file name (lastPathComponent) alphabetically.
    /// Uses localized case-insensitive comparison.
    public func sortedByFileName() -> [URL] {
        sorted(by: { $0.sortCompareFileName($1) })
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

// MARK: - file size

extension URL {
    static let allocatedSizeResourceKeys: Set<URLResourceKey> = [
        .isRegularFileKey,
        .fileAllocatedSizeKey,
        .totalFileAllocatedSizeKey,
    ]

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
        guard let enumerator = FileManager.default.enumerator(
            at: self,
            includingPropertiesForKeys: Array(URL.allocatedSizeResourceKeys),
            options: [],
            errorHandler: errorHandler
        ) else {
            return nil
        }

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
        guard let resourceValues = try? resourceValues(forKeys: URL.allocatedSizeResourceKeys) else { return nil }

        // We only look at regular files.
        guard resourceValues.isRegularFile == true else { return 0 }

        // To get the file's size we first try the most comprehensive value in terms of what
        // the file may use on disk. This includes metadata, compression (on file system
        // level) and block size.
        // In case totalFileAllocatedSize is unavailable we use the fallback value (excluding
        // meta data and compression) This value should always be available.
        return UInt64(
            resourceValues.totalFileAllocatedSize
                ?? resourceValues.fileAllocatedSize
                ?? 0
        )
    }

    public var fileSize: Int? {
        guard let value = try? resourceValues(forKeys: [.fileSizeKey]) else { return nil }
        return value.fileSize
    }
}
