import AppKit

extension NSView {
    @objc
    open func centerInSuperview() {
        guard let superview else { return }

        frame.origin = NSPoint(
            x: (superview.frame.width / 2) - (frame.width / 2),
            y: (superview.frame.height / 2) - (frame.height / 2)
        )
    }

    public func centerVerticalInSuperview() {
        guard let superview else { return }

        frame.origin = NSPoint(
            x: frame.origin.x,
            y: (superview.frame.height / 2) - (frame.height / 2)
        )
    }

    public func centerHorizontalInSuperview() {
        guard let superview else { return }

        frame.origin = NSPoint(
            x: (superview.frame.width / 2) - (frame.width / 2),
            y: frame.origin.y
        )
    }

    @objc
    open func convertEventToSuperview(event: NSEvent) -> NSPoint {
        let localPoint = convert(event.locationInWindow, from: nil)
        let svLocation = convert(localPoint, to: superview)
        return svLocation
    }

    @objc
    open func convertToSuperview(localPoint: NSPoint) -> NSPoint {
        let svLocation = convert(localPoint, to: superview)
        return svLocation
    }

    @objc
    open func setFrameWidth(_ width: CGFloat) {
        guard width >= 0 && frame.size.height >= 0 else { return }

        setFrameSize(
            NSSize(width: width, height: frame.size.height)
        )
    }

    @objc
    open func setFrameHeight(_ height: CGFloat) {
        guard height >= 0 && frame.size.width >= 0 else { return }

        setFrameSize(
            NSSize(width: frame.size.width, height: height)
        )
    }

    /// convenience for animating a view's horizontal location
    @objc
    open func moveTo(x position: CGFloat, duration: Double = 0.1) {
        moveTo(point: NSPoint(x: position, y: frame.origin.y),
               duration: duration)
    }

    /// animated setFrameOrigin
    @objc
    open func moveTo(point: NSPoint, duration: Double = 0.1) {
        guard layer != nil, duration > 0 else {
            setFrameOrigin(point)
            return
        }
        let anim = CABasicAnimation()
        anim.fromValue = NSValue(point: frame.origin)
        anim.toValue = NSValue(point: point)
        anim.duration = duration
        layer?.add(anim, forKey: "position")

        // trigger the animation and move the object
        setFrameOrigin(point)
    }

    @objc
    open func sizeTo(_ size: CGSize, duration: Double = 0.2) {
        guard layer != nil, duration > 0 else {
            setFrameSize(size)
            return
        }
        let anim = CABasicAnimation()
        anim.fromValue = frame.size
        anim.toValue = size
        anim.duration = duration
        layer?.add(anim, forKey: "bounds.size")

        // trigger the animation and move the object
        setFrameSize(size)
    }

    @objc
    open func opacityFadeIn(_ duration: Double = 0.3) {
        layer?.opacityFadeIn(duration)
    }

    @objc
    open func opacityFadeOut(_ duration: Double = 0.3) {
        layer?.opacityFadeOut(duration)
    }

    public func enableCursorRects() {
        guard let window, !window.areCursorRectsEnabled else { return }
        window.enableCursorRects()
    }

    public func disableCursorRects() {
        guard let window, window.areCursorRectsEnabled else { return }
        window.disableCursorRects()
    }

    public func isMouseInFrame(_ event: NSEvent) -> Bool {
        // Convert mouse location to the view coordinates
        let mouseLocation = convert(event.locationInWindow, from: nil)
        let rect = NSRect(origin: .zero, size: frame.size)
        return rect.contains(mouseLocation)
    }
}

extension NSView {
    public func rasterize(bounds: NSRect? = nil) -> NSBitmapImageRep? {
        let bounds = bounds ?? self.bounds

        guard let bitmap = bitmapImageRepForCachingDisplay(in: bounds) else {
            return nil
        }

        bitmap.size = bounds.size

        cacheDisplay(in: bounds, to: bitmap)

        return bitmap
    }

    @objc open func rasterize(format: NSBitmapImageRep.FileType) -> Data? {
        rasterize()?.representation(using: format, properties: [:])
    }
}
