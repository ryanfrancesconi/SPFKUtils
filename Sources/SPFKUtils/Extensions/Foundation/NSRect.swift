// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/SPFKUtils

import Foundation

extension NSRect {
    public init(size: NSSize) {
        self = NSRect(origin: .zero, size: size)
    }

    public init(width: CGFloat, height: CGFloat) {
        self = NSRect(x: 0, y: 0, width: width, height: height)
    }
}
