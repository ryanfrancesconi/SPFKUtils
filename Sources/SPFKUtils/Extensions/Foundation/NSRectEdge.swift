// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/SPFKUtils

import Foundation

extension NSRectEdge {
    public var name: String {
        switch self {
        case .minX:
            return "minX"
        case .minY:
            return "minY"
        case .maxX:
            return "maxX"
        case .maxY:
            return "maxY"
        @unknown default:
            return String(describing: rawValue)
        }
    }
}
