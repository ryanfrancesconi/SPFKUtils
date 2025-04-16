// Borrowed from https://github.com/orchetect/OTCore
// May include the dependency in the future

import Foundation

extension StringProtocol {
    public var trimmed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// **OTCore:**
    /// Returns a string removing all characters from the passed `CharacterSet`s.
    ///
    /// Example:
    ///
    ///     "A string 123".removing(.whitespaces)`
    ///     "A string 123".removing(.letters, .decimalDigits)`
    ///
    public func removing(
        _ characterSet: CharacterSet,
        _ characterSets: CharacterSet...
    ) -> String {
        let mergedCharacterSet = characterSets.isEmpty
            ? characterSet
            : characterSets.reduce(into: characterSet, +=)

        return components(separatedBy: mergedCharacterSet)
            .joined()
    }
}

extension CharacterSet {
    /// **OTCore:**
    /// Same as `lhs.union(rhs)`.
    public static func + (lhs: Self, rhs: Self) -> Self {
        lhs.union(rhs)
    }

    /// **OTCore:**
    /// Same as `lhs.formUnion(rhs)`.
    public static func += (lhs: inout Self, rhs: Self) {
        lhs.formUnion(rhs)
    }

    /// **OTCore:**
    /// Same as `lhs.subtracting(rhs)`.
    public static func - (lhs: Self, rhs: Self) -> Self {
        lhs.subtracting(rhs)
    }

    /// **OTCore:**
    /// Same as `lhs.subtract(rhs)`.
    public static func -= (lhs: inout Self, rhs: Self) {
        lhs.subtract(rhs)
    }
}
