import AppKit

extension NSColor {
    public var isLight: Bool {
        var r: CGFloat = 0.0
        var g: CGFloat = 0.0
        var b: CGFloat = 0.0
        var a: CGFloat = 0.0

        getRed(&r, green: &g, blue: &b, alpha: &a)

        let brightness = ((r * 299) + (g * 587) + (b * 114)) / 1000
        return brightness >= 0.5
    }

    // untested
    public convenience init(rgb: Int) {
        let r = (rgb >> 16) & 255
        let g = (rgb >> 8) & 255
        let b = rgb & 255

        self.init(
            red: CGFloat(r) / 255,
            green: CGFloat(g) / 255,
            blue: CGFloat(b) / 255,
            alpha: 1
        )
    }

    public convenience init?(htmlString: String) {
        let hexColor = htmlString.replacingOccurrences(of: "#", with: "")

        let scanner = Scanner(string: hexColor)
        var hexNumber: UInt64 = 0

        guard scanner.scanHexInt64(&hexNumber) else { return nil }

        let red = CGFloat((hexNumber & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((hexNumber & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat((hexNumber & 0x0000FF) >> 0) / 255.0
        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }

    public var hexString: String {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0

        getRed(&r, green: &g, blue: &b, alpha: &a)

        return String(
            format: "#%02X%02X%02X",
            Int(r * 0xFF),
            Int(g * 0xFF),
            Int(b * 0xFF)
        )
    }

    public static var random: NSColor {
        let r = CGFloat.random(in: 0.05 ... 0.95)
        let g = CGFloat.random(in: 0.05 ... 0.95)
        let b = CGFloat.random(in: 0.05 ... 0.95)

        return NSColor(calibratedRed: r, green: g, blue: b, alpha: 1.0)
    }

    public static var randomPastel: NSColor {
        NSColor(calibratedRed: CGFloat.random(in: 0.05 ... 0.95),
                green: 0.3,
                blue: 0.2,
                alpha: 1.0)
    }

    public static var randomGray: NSColor {
        let value = CGFloat.random(in: 0.0 ... 1.0)
        
        let c = NSColor(calibratedRed: value,
                        green: value,
                        blue: value,
                        alpha: 1.0)
        return c
    }

    public func darker(by amount: CGFloat = 0.2) -> NSColor {
        shadow(withLevel: amount) ?? self
    }

    public func lighter(by amount: CGFloat = 0.2) -> NSColor {
        highlight(withLevel: amount) ?? self
    }

    public func changeBrightness(by amount: CGFloat) -> NSColor {
        var color = self

        // Don' use the hue property unless it's calibrated or device RGB
        let needsConversion = colorSpace != .deviceRGB && colorSpace != .genericRGB

        if needsConversion, let value = usingColorSpace(.deviceRGB) {
            color = value
        }

        // this can throw a fatal error if the color if incompatible color space
        return NSColor(calibratedHue: color.hueComponent,
                       saturation: color.saturationComponent,
                       brightness: color.brightnessComponent + amount,
                       alpha: color.alphaComponent)
    }

    public func isApproximately(color: NSColor) -> Bool {
        let difference: CGFloat = 0.1

        let r = abs(redComponent - color.redComponent)
        let g = abs(greenComponent - color.greenComponent)
        let b = abs(blueComponent - color.blueComponent)

        return r < difference && g < difference && b < difference
    }
}

extension NSColor {
    public var floatArray: SIMD4<Float> {
        var color = self
        let needsConversion = colorSpace != .deviceRGB && colorSpace != .genericRGB

        if needsConversion, let value = usingColorSpace(.genericRGB) {
            color = value
        }

        return .init(color.redComponent.float, color.greenComponent.float, color.blueComponent.float, color.alphaComponent.float)
    }

    public var rgbaString: String? {
        var color = self
        let needsConversion = colorSpace != .deviceRGB && colorSpace != .genericRGB

        if needsConversion, let value = usingColorSpace(.genericRGB) {
            color = value
        }

        return "\(color.redComponent),\(color.greenComponent),\(color.blueComponent),\(color.alphaComponent)"
    }

    public static func parse(rgbaString: String) -> NSColor? {
        let components = rgbaString
            .components(separatedBy: ",")
            .compactMap { $0.trimmed.cgFloat }

        guard components.count >= 4 else { return nil }

        let color = NSColor(calibratedRed: components[0],
                            green: components[1],
                            blue: components[2],
                            alpha: components[3]).usingColorSpace(.genericRGB)

        return color
    }
}
