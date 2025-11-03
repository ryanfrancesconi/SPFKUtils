import Foundation
import OrderedCollections

public struct URLProperties: Hashable, Codable {
    public private(set) var url: URL
    public private(set) var finderTags: FinderTagGroup
    public private(set) var modificationDate: Date?
    public private(set) var fileSize: UInt64?
    public private(set) var fileSizeString: String?

    public var dictionary: OrderedDictionary<String, String> { [
        "Path": url.path,
        "Date Modified": modificationDate?.mediumString ?? "",
        "Tags": finderTags.stringValue,
        "Size": fileSizeString ?? "",
    ] }

    public var isModified: Bool {
        url.modificationDate != modificationDate
    }

    public init(url: URL) {
        self.url = url
        self.finderTags = FinderTagGroup(url: url)

        self.modificationDate = url.modificationDate

        fileSize = url.regularFileAllocatedSize

        if let fileSize {
            fileSizeString = FileSystem.byteCountToString(fileSize.int64)
        }
    }

    public mutating func refresh() {
        self = URLProperties(url: url)
    }
}
