import Foundation

// https://developer.apple.com/documentation/coreservices/file_metadata/mditem/common_metadata_attribute_keys
extension URL {
    static let userTagsKey = "com.apple.metadata:_kMDItemUserTags"

    /// The values of all tags attached to the URL
    public var tagNames: [String] {
        do {
            let data = try extendedAttributeValue(forName: Self.userTagsKey)

            let tags: [String] = try PropertyListDecoder().decode(
                [String].self,
                from: data
            )

            return tags

        } catch {
            // Log.error(error)
            return []
        }
    }

    public var tagColors: [TagColor] {
        tagNames.compactMap { TagColor(label: $0) }
    }

    public var finderTags: [FinderTag] {
        var tags = [FinderTag]()

        for string in tagNames {
            guard let tagColor = TagColor(label: string) else {
                tags.append(
                    FinderTag(label: string)
                )
                continue
            }

            tags.append(
                FinderTag(tagColor: tagColor)
            )
        }

        return tags
    }

    public func set(tagColors: [TagColor]) throws {
        let labels: [String] = tagColors.compactMap { $0.label }
        try set(tagNames: labels)
    }

    public func set(tagNames: [String]) throws {
        guard tagNames.isNotEmpty else {
            try removeAllTags()
            return
        }

        let data = try tagNames.propertyListData()
        try setExtendedAttribute(name: Self.userTagsKey, value: data)
    }

    public func removeAllTags() throws {
        let empty: [String] = []

        try setExtendedAttribute(
            name: Self.userTagsKey,
            value: try empty.propertyListData()
        )
    }
}

extension Array where Element == URL {
    public func set(tagNames: [String]) throws {
        for url in self {
            try url.set(tagNames: tagNames)
        }
    }

    public func set(tagColors: [TagColor]) throws {
        for url in self {
            try url.set(tagColors: tagColors)
        }
    }
}
