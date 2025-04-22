// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/SPFKUtils

import Foundation

extension FileManager {
    public func modificationDateForFileAtPath(path: String) -> NSDate? {
        guard let attributes = try? attributesOfItem(atPath: path) else { return nil }
        return attributes[.modificationDate] as? NSDate
    }

    public func creationDateForFileAtPath(path: String) -> NSDate? {
        guard let attributes = try? attributesOfItem(atPath: path) else { return nil }
        return attributes[.creationDate] as? NSDate
    }

    public func isInTrash(_ url: URL) -> Bool {
        var relationship: URLRelationship = .other

        try? getRelationship(
            &relationship,
            of: .trashDirectory,
            in: .allDomainsMask,
            toItemAt: url
        )

        return relationship == .contains
    }
}
