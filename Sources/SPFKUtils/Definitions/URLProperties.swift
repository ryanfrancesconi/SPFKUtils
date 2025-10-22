import Foundation

public struct URLProperties: Hashable, Codable {
    public private(set) var url: URL
    public private(set) var finderTags: FinderTagGroup

    public private(set) var modificationDate: Date?
    public private(set) var fileSize: UInt64?

    public var isModified: Bool {
        url.modificationDate != modificationDate
    }

    public init(url: URL) {
        self.url = url
        self.finderTags = FinderTagGroup(url: url)

        modificationDate = url.modificationDate
        fileSize = url.regularFileAllocatedSize
    }
}
