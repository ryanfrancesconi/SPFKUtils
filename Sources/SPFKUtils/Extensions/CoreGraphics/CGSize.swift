import CoreGraphics
import Foundation

extension CGSize {
    /// Initializes a square with equal width and height.
    public init(square sideLength: CGFloat) {
        self.init(width: sideLength, height: sideLength)
    }
}
