// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-utils

import Foundation

extension NumberFormatter {
    public static func decimalString(from value: Int) -> String? {
        let number = NSNumber(integerLiteral: value)
        return decimalString(from: number)
    }

    public static func decimalString(from value: Double) -> String? {
        let number = NSNumber(floatLiteral: value)
        return decimalString(from: number)
    }

    public static func decimalString(from number: NSNumber) -> String? {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal

        return numberFormatter.string(from: number)
    }
}
