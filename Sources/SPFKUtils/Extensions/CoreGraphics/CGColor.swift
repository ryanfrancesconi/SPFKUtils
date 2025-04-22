// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/SPFKUtils

import AppKit
import CoreGraphics

extension CGColor {
    // TODO: Could go in OTCore
    /// Converts a `CGColor` to an `NSColor` instance.
    public var nsColor: NSColor? {
        NSColor(cgColor: self)
    }
}
