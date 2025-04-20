// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/SPFKUtils

import Foundation

// MARK: - Normalization Helpers

extension Double {
    /// Extension to calculate scaling factors, useful for UI controls
    /// Return a value on [minimum, maximum] to a [0, 1] range, according to a taper
    ///
    /// - Parameters:
    ///   - to: Source range (cannot include zero if taper is not positive)
    ///   - taper: Must be a positive number, taper = 1 is linear
    ///
    public func normalized(from range: ClosedRange<Double>,
                           taper: Double = 1) -> Double {
        assert(taper > 0, "Cannot have non-positive taper.")
        return pow((self - range.lowerBound) / (range.upperBound - range.lowerBound), 1.0 / taper)
    }

    /// Return a value on [0, 1] to a [minimum, maximum] range, according to a taper
    ///
    /// - Parameters:
    ///   - to: Target range (cannot contain zero if taper is not positive)
    ///   - taper: For taper > 0, there is an algebraic curve, taper = 1 is linear, and taper < 0 is exponential
    ///
    public func denormalized(to range: ClosedRange<Double>,
                             taper: Double = 1) -> Double {
        assert(taper > 0, "Cannot have non-positive taper.")
        return range.lowerBound + (range.upperBound - range.lowerBound) * pow(self, taper)
    }
}
