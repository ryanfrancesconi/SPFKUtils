// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/SPFKUtils

import CoreGraphics

extension CGRect {
    /// Returns the largest centered square that fits within the rect, maintaining the coordinate system.
    public func largestCenteredSquare() -> CGRect {
        if width == height {
            // already a square
            return self
        }
        
        if width > height {
            return CGRect(origin: .init(x: origin.x + ((width - height) / 2),
                                        y: origin.y),
                          size: .init(width: height, height: height))
        } else {
            return CGRect(origin: .init(x: origin.x,
                                        y: origin.y + ((height - width) / 2)),
                          size: .init(width: width, height: width))
        }
    }
}
