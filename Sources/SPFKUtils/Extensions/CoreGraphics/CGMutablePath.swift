// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/SPFKUtils

import CoreGraphics

extension CGMutablePath {
    /// Safely create round rect checking that the rect is big enough to support the cornerRadius
    public static func createRoundRect(in rect: CGRect, cornerRadius: CGFloat) -> CGMutablePath {
        let path = CGMutablePath()

        guard rect.size.width > (cornerRadius * 2) && rect.size.height > (cornerRadius * 2) else {
            Log.error("Invalid size passed in", rect, "cornerRadius", cornerRadius)

            path.addRect(rect)
            return path
        }

        path.addRoundedRect(
            in: rect,
            cornerWidth: cornerRadius,
            cornerHeight: cornerRadius
        )

        return path
    }
}
