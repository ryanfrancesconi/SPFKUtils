// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/SPFKUtils

import CoreGraphics

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
