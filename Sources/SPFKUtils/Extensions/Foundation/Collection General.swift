// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/SPFKUtils

import Foundation
import OTCore

extension Sequence where Element: Hashable {
    /// Key: The element. Value: how many times it occurs.
    public var elementQuantity: [Element: Int] {
        reduce(into: [:]) {
            $0[$1, default: 0] += 1
        }
    }
}

extension Collection {
    /// A Boolean value indicating whether the collection is not empty.
    public var isNotEmpty: Bool {
        !isEmpty
    }
}

extension RangeReplaceableCollection where Iterator.Element: ExpressibleByIntegerLiteral {
    /// Initialize array with zeros, ~10x faster than append for array of size 4096
    /// - parameter count: Number of elements in the array
    public init(zeros count: Int) {
        self.init(repeating: 0, count: count)
    }
}

public extension Array where Element: Equatable {
    mutating func move(_ item: Element, to newIndex: Index) {
        if let index = firstIndex(of: item), index != newIndex {
            move(at: index, to: newIndex)
        }
    }

    mutating func bringToFront(item: Element) {
        move(item, to: 0)
    }

    mutating func sendToBack(item: Element) {
        move(item, to: endIndex - 1)
    }
}

extension Array {
    // TODO: this may be buggy depending whether the index is before or after the index to move. it should be unit tested.
    mutating func move(at index: Index, to newIndex: Index) {
        insert(remove(at: index), at: newIndex)
    }
}
