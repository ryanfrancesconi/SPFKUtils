// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/SPFKUtils

import AppKit
import Foundation

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

public struct FinderTagGroup: Hashable, Codable, CustomStringConvertible {
    public var tags: [FinderTag] = .init()
    public private(set) var description: String = ""

    public var defaultColor: NSColor? {
        guard let first = tags.first,
              let nsColor = first.tagColor.nsColor else {
            return nil
        }

        return nsColor
    }

    public func tagColors() -> [TagColor] {
        tags.filter {
            $0.tagColor != .none
        }
        .map {
            $0.tagColor
        }
    }

    public init() {}

    public init(url: URL) {
        self = FinderTagGroup(tags: url.finderTags)
    }

    public init(tags: [FinderTag]) {
        self.tags = tags

        self.description = tags.map {
            $0.label
        }
        .sorted()
        .joined(separator: ", ")
    }
}
