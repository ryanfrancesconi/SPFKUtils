#if os(macOS)
    import Foundation

    public struct URLProperties: Hashable, Codable, Sendable {
        public private(set) var url: URL
        public var finderTags: FinderTagGroup
        public private(set) var creationDate: Date?
        public private(set) var modificationDate: Date?
        public private(set) var fileSize: UInt64?
        public private(set) var fileSizeString: String?

        public var isModified: Bool {
            url.modificationDate != modificationDate
        }

        public init(url: URL) {
            self.url = url
            finderTags = FinderTagGroup(url: url)
            creationDate = url.creationDate
            modificationDate = url.modificationDate

            fileSize = url.regularFileAllocatedSize

            if let fileSize {
                fileSizeString = FileSystem.byteCountToString(fileSize.int64)
            }
        }
    }




#endif
