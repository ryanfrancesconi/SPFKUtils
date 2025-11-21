// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/SPFKUtils

import Foundation

public enum DirectoryEvent: Hashable, Sendable {
    case new(files: Set<URL>, source: URL)
    case removed(files: Set<URL>, source: URL)

    public var isNew: Bool {
        switch self {
        case .new: return true
        case .removed: return false
        }
    }

    public var source: URL {
        switch self {
        case let .new(files: _, source: source):
            return source

        case let .removed(files: _, source: source):
            return source
        }
    }

    public var files: Set<URL> {
        switch self {
        case let .new(files: files, source: _):
            return files

        case let .removed(files: files, source: _):
            return files
        }
    }
}
