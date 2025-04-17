import CoreGraphics
import CoreText
import Foundation

extension CGContext {
    public func disableAntiAliasing() {
        setAllowsFontSmoothing(false)
        setShouldSmoothFonts(false)
        setAllowsAntialiasing(false)
        setShouldAntialias(false)
        setAllowsFontSubpixelPositioning(false)
        setShouldSubpixelPositionFonts(false)
        setAllowsFontSubpixelQuantization(false)
        setShouldSubpixelQuantizeFonts(false)
    }
}

extension CGContext {
    public enum DrawLocation {
        case passive
        case atOrigin(CGPoint)
        case centered(inRect: CGRect)
    }

    /// Draws an attributed string into a graphics context.
    ///
    /// This method is preferable over the built-in `NSAttributedString().draw(at:)` which relies on the view having focus and may not work when a view is invisible or out of view.
    public func draw(_ attributedString: NSAttributedString,
                     location: DrawLocation) {
        // convert string to CoreText line
        let line = CTLineCreateWithAttributedString(attributedString)

        // get bounding frame of the text
        let stringRect = CTLineGetImageBounds(line, self)

        switch location {
        case .passive:
            break

        case let .atOrigin(point):
            textPosition = point

        case let .centered(inRect):
            // calculate position
            let areaCenter = inRect.center
            let centeredOrigin = CGPoint(x: areaCenter.x - (stringRect.width / 2),
                                         y: areaCenter.y - (stringRect.height / 2))
            textPosition = centeredOrigin
        }

        // draw into context
        CTLineDraw(line, self)
    }
}
