import AppKit

extension NSScreen {
    public var readableDescription: String {
        var out = ""

        if #available(macOS 12, *) {
            out = localizedName
        }

        if self == NSScreen.main {
            out += " (Main 🖥)"
        }

        out += ", frame: \(frame), visible: \(visibleFrame)"

        if #available(macOS 12, *) {
            out += ", Refresh Rate: \(maximumFramesPerSecond) hz, Interval: \(maximumRefreshInterval)"
        }
        return out
    }

    public static var menubarScreen: NSScreen? {
        screens.first
    }

    public static var best: NSScreen? {
        menubarScreen ?? main
    }

    public func clamp(windowRect rect: NSRect) -> NSRect {
        let screenRect = visibleFrame

        // Log.debug("Clamping to screen", localizedName, screenRect)

        var rect = rect
        rect.size.width = min(screenRect.width, rect.size.width)
        rect.size.height = min(screenRect.height, rect.size.height)

        var clampedRect = NSRect()

        clampedRect.origin.x = max(screenRect.origin.x, rect.origin.x)
        clampedRect.origin.y = max(screenRect.origin.y, rect.origin.y)

        clampedRect.size.width = min(screenRect.size.width - rect.origin.x, rect.size.width)
        clampedRect.size.height = min(screenRect.size.height - rect.origin.y, rect.size.height)

        if clampedRect.size.width < 30 {
            clampedRect.origin.x = screenRect.origin.x
            clampedRect.size.width = rect.width
        }

        if clampedRect.size.height < 30 {
            clampedRect.origin.y = screenRect.origin.y
            clampedRect.size.height = rect.height
        }

        return clampedRect
    }
}

extension NSScreen {
    public static func screen(at point: NSPoint) -> NSScreen? {
        for screen in NSScreen.screens where screen.visibleFrame.contains(point) {
            return screen
        }

        return nil
    }
}
