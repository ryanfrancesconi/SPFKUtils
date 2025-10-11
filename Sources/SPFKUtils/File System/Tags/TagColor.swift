import AppKit
import Foundation
import XAttr

// swiftformat:disable consecutiveSpaces

/// Default macOS label colors
public enum TagColor: Int, Hashable, CaseIterable, Comparable, Codable {
    public static func < (lhs: TagColor, rhs: TagColor) -> Bool {
        lhs.name.standardCompare(with: rhs.name)
    }

    case none   // 0
    case gray   // 1
    case green  // 2
    case purple // 3
    case blue   // 4
    case yellow // 5
    case red    // 6
    case orange // 7

    /// These are the data elements stored in
    /// com.apple.metadata:_kMDItemUserTags
    /// It's unfortunate to hardcode these strings
    /// but the convenience is probably worth it.
    public var label: String {
        switch self {
        // the associated color is black, "none more black"
        case .none:     return ""           // 0
        case .gray:     return "Gray\n1"    // 1
        case .green:    return "Green\n2"   // 2
        case .purple:   return "Purple\n3"  // 3
        case .blue:     return "Blue\n4"    // 4
        case .yellow:   return "Yellow\n5"  // 5
        case .red:      return "Red\n6"     // 6
        case .orange:   return "Orange\n7"  // 7
        }
    }

    public var nsColor: NSColor? {
        Self.array[self]
    }

    public var cgColor: CGColor? {
        nsColor?.cgColor
    }

    public var name: String {
        switch self {
        case .none:     return "None"       // 0
        case .gray:     return "Gray"       // 1
        case .green:    return "Green"      // 2
        case .purple:   return "Purple"     // 3
        case .blue:     return "Blue"       // 4
        case .yellow:   return "Yellow"     // 5
        case .red:      return "Red"        // 6
        case .orange:   return "Orange"     // 7
        }
    }

    public init?(name: String) {
        for item in Self.allCases where item.name == name {
            self = item
            return
        }

        return nil
    }

    public init?(label: String) {
        for item in Self.allCases where item.label == label {
            self = item
            return
        }

        return nil
    }

    /// merges NSWorkspace fileLabels and fileLabelColors into one object
    static let array: [TagColor: NSColor] = {
        var array = [TagColor: NSColor]()

        // You can listen for notifications named didChangeFileLabelsNotification
        // to be notified when file labels change.
        let tags = NSWorkspace.shared.fileLabels

        // This array has the same number of elements as fileLabels,
        // and the color at a given index corresponds to the label at the same index.
        let colors = NSWorkspace.shared.fileLabelColors

        for i in 0 ..< tags.count {
            guard colors.indices.contains(i) else {
                // according to Apple this array should match
                continue
            }

            let tag = tags[i]

            guard let label = TagColor(name: tag) else {
                Log.error("Unknown label: \(tag)")
                continue
            }

            array[label] = colors[i]
        }

        return array
    }()
}

extension Array where Element == TagColor {
    public func propertyListData() throws -> Data {
        let labels: [String] = self.map { $0.label }
        return try labels.propertyListData()
    }
}

extension Array where Element == String {
    public func propertyListData() throws -> Data {
        try PropertyListSerialization.data(
            fromPropertyList: self,
            format: .binary,
            options: 0
        )
    }
}

// swiftformat:enable consecutiveSpaces
