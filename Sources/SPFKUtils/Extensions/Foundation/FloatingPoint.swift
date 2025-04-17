
import Foundation

extension BinaryFloatingPoint {
    public func round(
        _ rule: FloatingPointRoundingRule = .toNearestOrAwayFromZero,
        divisor: any BinaryFloatingPoint
    ) -> Self {
        let divisor = Self(divisor)

        guard divisor > 0 else { return self }

        return divisor * (self / divisor).rounded(rule)
    }
}
