// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/SPFKUtils

import AudioToolbox
import Foundation

/// MARK: - dB helpers
extension AUValue {
    /// Convert to dB from a linear
    public var dBValue: AUValue {
        20.0 * log10(self)
    }

    /// Convert from a dB value
    public var linearValue: AUValue {
        pow(10.0, self / 20)
    }

    public func dBString(decimalPlaces: Int = 1, dBMin: AUValue = -90) -> String {
        var out = ""
        let value = self

        let roundedDb = abs(
            value.rounded(decimalPlaces: 1)
        )

        if value <= dBMin {
            out = "∞"

        } else if roundedDb == 0 {
            out = "0 dB"

        } else {
            let sign = value > 0 ? "+" : "-"
            out = "\(sign)\(roundedDb) dB"
        }

        return out
    }
}

// MARK: - Normalization Helpers

/// Extension to calculate scaling factors, useful for UI controls
extension AUValue {
    /// Return a value on [minimum, maximum] to a [0, 1] range, according to a taper
    ///
    /// - Parameters:
    ///   - to: Source range (cannot include zero if taper is not positive)
    ///   - taper:Must be a positive number, taper = 1 is linear
    ///
    public func normalized(from range: ClosedRange<AUValue>,
                           taper: AUValue = 1) -> AUValue {
        assert(taper > 0, "Cannot have non-positive taper.")
        return powf((self - range.lowerBound) / (range.upperBound - range.lowerBound), 1.0 / taper)
    }

    /// Return a value on [0, 1] to a [minimum, maximum] range, according to a taper
    ///
    /// - Parameters:
    ///   - to: Target range (cannot contain zero if taper is not positive)
    ///   - taper: For taper > 0, there is an algebraic curve, taper = 1 is linear, and taper < 0 is exponential
    ///
    public func denormalized(to range: ClosedRange<AUValue>,
                             taper: AUValue = 1) -> AUValue {
        assert(taper > 0, "Cannot have non-positive taper.")
        return range.lowerBound + (range.upperBound - range.lowerBound) * powf(self, taper)
    }
}
