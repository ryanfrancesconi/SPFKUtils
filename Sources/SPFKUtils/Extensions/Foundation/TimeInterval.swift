// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/SPFKUtils

import Darwin
import Foundation

/// Duration in real-time seconds of 1 tick in mach (host) time domain.
public let machTimeSecondsPerTick: Double = {
    var tinfo = mach_timebase_info()
    let err = mach_timebase_info(&tinfo); _ = err
    let timecon = Double(tinfo.numer) / Double(tinfo.denom)
    return timecon * 0.000_000_001
}()

/// Number of mach (host) time domain ticks in 1 second of real time.
public let machTimeTicksPerSecond: Double = {
    var tinfo = mach_timebase_info()
    let err = mach_timebase_info(&tinfo); _ = err
    let timecon = Double(tinfo.denom) / Double(tinfo.numer)
    return timecon * 1000000000
}()

extension TimeInterval {
    /// Converts the TimeInterval (seconds) to host (mach) time.
    /// Note that this conversion is lossy due to floating-point precision.
    public func convertedToHostTime() -> UInt64 {
        UInt64(self / machTimeSecondsPerTick)
    }
}

extension UInt64 {
    /// Converts the host (mach) time to TimeInterval (seconds).
    /// Note that this conversion is lossy due to floating-point precision.
    public func hostTimeConvertedToTimeInterval() -> TimeInterval {
        Double(self) / machTimeTicksPerSecond
    }
}
