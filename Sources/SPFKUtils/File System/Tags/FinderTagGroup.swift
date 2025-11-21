// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/SPFKUtils

import AppKit
import Foundation

/// Describes the tags found and set by the finder such as colored labels
public struct FinderTagGroup: Hashable, Codable, Sendable {
    public static let defaultTags: FinderTagGroup = .init(
        tags: Set(
            TagColor.allCases.map {
                FinderTagDescription(tagColor: $0)
            }
        )
    )

    public var tags: Set<FinderTagDescription> = .init()

    public var stringValue: String {
        tags.map {
            $0.label
        }
        .sorted()
        .joined(separator: ", ")
    }

    public var defaultColor: NSColor? {
        guard let first = tags.first(where: { tag in
            tag.tagColor != .none
        }) else { return nil }

        guard let nsColor = first.tagColor.nsColor else {
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

    public init(tags: Set<FinderTagDescription>) {
        self.tags = tags
    }

    public mutating func insert(colors: Set<FinderTagDescription>) {
        self.tags = self.tags.filter { $0.tagColor == .none }
        let colors = colors.filter { $0.tagColor != .none }

        self.tags = self.tags.union(colors)
    }
}
