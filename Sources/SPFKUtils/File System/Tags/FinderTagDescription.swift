// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/SPFKUtils

import AppKit
import Foundation

/// Describes the tags found and set by the finder such as colored labels or custom strings
public struct FinderTagDescription: Hashable, Codable {
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
