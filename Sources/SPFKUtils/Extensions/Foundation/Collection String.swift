// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/SPFKUtils

import Foundation

// MARK: - Shorthand/convenience

extension Collection {
    /// Useful for messages to the user describing the array size.
    ///
    /// 12 coconut\(s)
    public var pluralString: String {
        count != 1 ? "s" : ""
    }
}

// MARK: - Delimited Strings

extension Sequence where Element: StringProtocol {
    /// Joins the elements into a single string, inserting the specified delimiter between elements.
    public func delimitedString(delimiter: String = ", ") -> String {
        joined(separator: delimiter)
    }

    public func contains(caseInsensitive find: String) -> Bool {
        contains { element in
            (element as? String)?.equalsIgnoringCase(find) == true
        }
    }
}

extension Sequence where Element: BinaryInteger {
    /// Joins the elements into a single string, inserting the specified delimiter between elements.
    public func delimitedString(delimiter: String = ", ") -> String {
        map { "\($0)" }
            .joined(separator: delimiter)
    }
}

extension Sequence where Element: FloatingPoint {
    /// Joins the elements into a single string, inserting the specified delimiter between elements.
    public func delimitedString(delimiter: String = ", ") -> String {
        map { "\($0)" }
            .joined(separator: delimiter)
    }
}

// MARK: - Map Conveniences

extension Sequence where Element: StringProtocol {
    /// Trims each element, omits empty elements, then returns an array of Integers.
    public func compactMapInt() -> [Int] {
        map(\.trimmed)
            .filter { !$0.isEmpty }
            .compactMap { Int($0) }
    }

    /// Trims each element, omits empty elements, then returns an array of Integers.
    public func compactMapUInt32() -> [UInt32] {
        map(\.trimmed)
            .filter { !$0.isEmpty }
            .compactMap { UInt32($0) }
    }

    /// Trims each element, omits empty elements, then returns an array of Integers.
    public func compactMapDouble() -> [Double] {
        map(\.trimmed)
            .filter { !$0.isEmpty }
            .compactMap { Double($0) }
    }
}
