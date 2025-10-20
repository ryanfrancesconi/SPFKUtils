import Foundation

/// 2D array of multiple float arrays
public typealias FloatChannelData = [[Float]]

/// Initialize a new FloatChannelData. Convenience function.
public func newFloatChannelData(channelCount: Int, length: Int) -> FloatChannelData {
    Array(
        repeating: Array<Float>(zeros: length),
        count: channelCount
    )
}
