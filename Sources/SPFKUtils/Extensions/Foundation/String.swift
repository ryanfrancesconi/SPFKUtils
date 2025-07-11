// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/SPFKUtils

import AudioToolbox

extension String {
    public static let nbsp: String = "\u{00A0}"
}

// MARK: - Character Filters

extension String {
    /// Retains only ASCII alphanumerics, `+`, `-`, and `_`
    public func onlyASCIIAlphanumericsPlusMinusUnderscore() -> String {
        let okayChars = "abcdefghijklmnopqrstuvwxyz ABCDEFGHIJKLKMNOPQRSTUVWXYZ1234567890+-_"
        return only(characters: okayChars)
    }

    /// Translate U+00A0 NO-BREAK SPACE to standard " "
    public func normalizedWhitespaces() -> String {
        removing(characters: Self.nbsp)
    }

    public var abbreviated: String {
        let input = onlyASCIIAlphanumericsPlusMinusUnderscore()
        let uppercaseLetters = input.only(.uppercaseLetters).prefix(4).string

        var output = ""

        if uppercaseLetters.count > 1 {
            output = uppercaseLetters

        } else if input.contains(" ") {
            let parts = input.components(separatedBy: " ")

            for i in 0 ..< parts.count {
                guard let letter = parts[i].first?.string else { continue }
                output += letter
            }

        } else if input.count > 1 {
            output = input.prefix(2).string
        }

        return output.uppercased()
    }

    public var fourCharCode: FourCharCode? {
        try? FourCharCode.from(string: self)
    }

    public var titleCased: String {
        return self
            .replacingOccurrences(
                of: "([A-Z])",
                with: " $1",
                options: .regularExpression,
                range: range(of: self)
            )
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .capitalized // If input is in llamaCase
    }
}

// MARK: - Comparison

extension String {
    // because I keep forgetting this syntax
    public func equalsIgnoringCase(_ string: String) -> Bool {
        caseInsensitiveCompare(string) == .orderedSame
    }

    public func standardCompare(with otherString: String, ascending: Bool = true) -> Bool {
        let comparisonResult = localizedStandardCompare(otherString)

        return ascending ?
            comparisonResult == .orderedAscending :
            comparisonResult == .orderedDescending
    }
}

// MARK: - Delimited Strings

extension StringProtocol {
    /// Splits a delimited string into elements.
    ///
    /// - Optionally, you can allow duplicates or allow empty elements.
    /// - Omits elements starting with a null character.
    public func splitDelimited(delimiter: String = ",",
                               allowDuplicates: Bool = false,
                               allowEmptyElements: Bool = false) -> [String] {
        let keywordArray = components(separatedBy: delimiter)
        var out: [String] = []

        for item in keywordArray {
            let word: String = item.trimmed

            guard word.first != "\0",
                  !word.isEmpty || allowEmptyElements,
                  !out.contains(word) || allowDuplicates else { continue }

            out.append(word.trimmed)
        }
        return out
    }
}

extension StringProtocol {
    /// Convenience conversion
    public var auValue: AUValue? {
        AUValue(self)
    }

    // useful for xml parsing
    public var boolValue: Bool {
        lowercased() == "true" || self == "1"
    }
}

extension String {
    public var urlEncoded: String? {
        addingPercentEncoding(withAllowedCharacters: .urlAllowed)
    }

    public var urlQueryEncoded: String? {
        urlEncoded?.replacingOccurrences(of: "%20", with: "+")
    }
}

extension CharacterSet {
    public static let urlAllowed: CharacterSet = {
        .alphanumerics.union(
            .init(charactersIn: "-._~")
        ) // as per RFC 3986
    }()
}
