
import AudioToolbox
import Foundation

/// Indicating either forward or backwards movement generally used
/// as a multipler for a value
public enum MovementDirection: Int {
    case forward = 1
    case backward = -1

    public var intValue: Int { rawValue }
    public var auValue: AUValue { AUValue(rawValue) }
    public var doubleValue: Double { Double(rawValue) }
    public var cgFloat: CGFloat { CGFloat(rawValue) }
    public var boolValue: Bool { self == .forward }

    public var inverse: MovementDirection {
        switch self {
        case .forward: return .backward
        case .backward: return .forward
        }
    }

    public init(sign: FloatingPointSign) {
        switch sign {
        case .plus:
            self = .forward

        case .minus:
            self = .backward
        }
    }

    public init(state: Bool) {
        switch state {
        case true:
            self = .forward

        case false:
            self = .backward
        }
    }
}
