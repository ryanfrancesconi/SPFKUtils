public struct FinderTag: Hashable, Codable {
    public var tagColor: TagColor
    public var label: String

    public init(tagColor: TagColor) {
        self.tagColor = tagColor
        self.label = tagColor.name
    }

    public init(label: String) {
        self.tagColor = TagColor.none
        self.label = label
    }
}
