import Foundation

public enum DirectoryEvent: Equatable {
    case new(files: [URL], source: URL)
    case removed(files: [URL], source: URL)

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

    public var files: [URL] {
        switch self {
        case let .new(files: files, source: _):
            return files

        case let .removed(files: files, source: _):
            return files
        }
    }
}
