// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/SPFKUtils

import Foundation
import UniformTypeIdentifiers

// MARK: - resourceValues, see URLTag for tag names

extension URL {
    public var mimeType: String {
        let genericType = "application/octet-stream"

        guard let type = UTType(filenameExtension: pathExtension),
              let mimetype = type.preferredMIMEType else {
            // hack, this isn't coming through.
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
        guard let value = try? resourceValues(forKeys: [.contentTypeKey]) else { return nil }
        return value.contentType?.localizedDescription
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
}
