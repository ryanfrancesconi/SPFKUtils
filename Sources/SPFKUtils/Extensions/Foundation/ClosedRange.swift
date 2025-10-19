import Foundation

extension ClosedRange<TimeInterval> {
    public var duration: TimeInterval {
        upperBound - lowerBound
    }
}
