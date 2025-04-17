import AppKit
import Foundation

extension NSLayoutConstraint {
    // TODO: move to NSView extension, or group with its constraint methods?
    public static func simpleVisualConstraints(view: NSView,
                                               direction: NSString = "H",
                                               padding1: Int = 0,
                                               padding2: Int = 0) -> [NSLayoutConstraint] {
        view.translatesAutoresizingMaskIntoConstraints = false

        let constraint = NSLayoutConstraint.constraints(withVisualFormat: "\(direction):|-\(padding1)-[view]-\(padding2)-|",
                                                        options: NSLayoutConstraint.FormatOptions(rawValue: 0),
                                                        metrics: nil,
                                                        views: ["view": view])
        return constraint
    }
}
