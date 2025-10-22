// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/SPFKUtils

import Foundation

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
