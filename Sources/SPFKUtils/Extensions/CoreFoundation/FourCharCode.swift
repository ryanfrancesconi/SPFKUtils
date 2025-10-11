// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/SPFKUtils

import Foundation

/* aka UInt32, defined in Kernel */
extension FourCharCode {
    /// Create a String representation of a FourCC.
    public func fourCharCodeToString() -> String? {
        let v1 = (self >> 24) & 0xFF
        let v2 = (self >> 16) & 0xFF
        let v3 = (self >> 8) & 0xFF
        let v4 = self & 0xFF

        // nullTerminatedUTF8
        let bytes: [UInt8] = [
            UInt8(v1),
            UInt8(v2),
            UInt8(v3),
            UInt8(v4),
            0,
        ]

        let out = String(cString: bytes)

        // "\a\u{fffd}\u{fffd}\u{fffd}"

        // The replacement character � (often displayed as a black rhombus with a white question mark)
        // is a symbol found in the Unicode standard at code point U+FFFD in the Specials table.
        // It is used to indicate problems when a system is unable to render a stream of data to a correct symbol.
        guard !out.contains("\u{fffd}") else { return nil }

        return out
    }

    public func fromHFSTypeCode() -> String {
        // returns with single quotes 'abcd' around the string
        guard var string = NSFileTypeForHFSTypeCode(self) else {
            return ""
        }

        if string.count == 6, string.first == "'", string.last == "'" {
            string = String(string.dropFirst().dropLast())
        }

        return string
    }

    /// Helper function to convert codes for Audio Units
    /// - parameter string: Four character string to convert
    public static func from(string: String) throws -> FourCharCode {
        let utf8 = string.utf8

        guard utf8.count == 4 else {
            throw NSError(description: "\(string) must be a 4 character string")
        }

        var out: FourCharCode = 0

        for char in utf8 {
            out <<= 8
            out |= FourCharCode(char)
        }

        return out
    }
}

extension OSStatus {
    /// Create a String representation of a FourCC.
    public func fourCharCodeToString() -> String? {
        guard self >= 0 else { return nil }

        return FourCharCode(self).fourCharCodeToString()
    }
}
