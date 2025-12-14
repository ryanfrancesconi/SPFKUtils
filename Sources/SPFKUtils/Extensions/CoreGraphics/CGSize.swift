// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-utils

import CoreGraphics
import Foundation

extension CGSize {
    /// Initializes a square with equal width and height.
    public init(equal sideLength: CGFloat) {
        self.init(width: sideLength, height: sideLength)
    }
}
