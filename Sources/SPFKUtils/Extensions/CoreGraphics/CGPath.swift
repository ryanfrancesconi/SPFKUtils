// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/SPFKUtils

import AppKit
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

extension CGPath {
    public func toCGImage(
        at size: CGSize,
        fillColor: NSColor,
        strokeColor: NSColor? = nil
    ) throws -> CGImage {
        let width = Int(size.width)
        let height = Int(size.height)

        guard let bitmap = NSBitmapImageRep(
            bitmapDataPlanes: nil,
            pixelsWide: width,
            pixelsHigh: height,
            bitsPerSample: 8,
            samplesPerPixel: 4,
            hasAlpha: true,
            isPlanar: false,
            colorSpaceName: .deviceRGB,
            bytesPerRow: width * 4,
            bitsPerPixel: 32
        ) else {
            throw NSError(description: "Failed to create bitmap image, width: \(width), height: \(height)")
        }

        guard let context = NSGraphicsContext(bitmapImageRep: bitmap) else {
            throw NSError(description: "Failed to create NSGraphicsContext from bitmap")
        }

        context.shouldAntialias = true
        context.imageInterpolation = .low

        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current = context

        context.cgContext.setFillColor(fillColor.cgColor)
        context.cgContext.addPath(self)
        context.cgContext.fillPath()

        if let strokeColor {
            context.cgContext.setStrokeColor(strokeColor.cgColor)
            context.cgContext.addPath(self)
            context.cgContext.strokePath()
        }

        context.flushGraphics()

        NSGraphicsContext.restoreGraphicsState()

        guard let image = bitmap.cgImage else {
            throw NSError(description: "Failed to convert bitmap to CGImage")
        }

        return image
    }
}
