// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/SPFKUtils

import AppKit
import Foundation

/// Describes the tags found and set by the finder such as colored labels
public struct FinderTagGroup: Hashable, Codable {
    public var tags: [FinderTagDescription] = .init()
    public private(set) var stringValue: String = ""

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

    public init(tags: [FinderTagDescription]) {
        self.tags = tags

        self.stringValue = tags.map {
            $0.label
        }
        .sorted()
        .joined(separator: ", ")
    }
}
