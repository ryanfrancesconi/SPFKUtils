// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/SPFKUtils

import Foundation

/// Represents the possible preprocessor flags
public enum BuildConfig: String, CustomStringConvertible, CaseIterable {
    case debug
    case beta
    case publicBeta
    case release
    case testing

    @inline(__always)
    public var description: String {
        switch self {
        case .debug: return "DEBUG"
        case .beta: return "BETA"
        case .publicBeta: return "PUBLIC BETA"
        case .release: return ""
        case .testing: return "Testing only"
        }
    }

    @inline(__always)
    public var isInternal: Bool {
        self == .debug || self == .beta || self == .testing
    }

    @inline(__always)
    public var isBeta: Bool {
        self != .release
    }

    @inline(__always)
    public var isRelease: Bool {
        self == .release
    }
}
