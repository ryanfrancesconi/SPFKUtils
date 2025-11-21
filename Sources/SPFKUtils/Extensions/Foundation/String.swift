import Foundation
import OTCore
import SPFKBase

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
}
