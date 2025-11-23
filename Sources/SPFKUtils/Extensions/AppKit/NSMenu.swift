#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit

extension NSMenu {
    /// Get: Returns first checked index.
    /// Set: Sets checked state for the given index, and removes checked state for all other indexes if present.
    public var firstCheckedIndex: Int {
        get {
            for i in 0 ..< items.count {
                let item = items[i]

                if item.state == .on {
                    return i
                }
            }
            return -1
        }

        set {
            for i in 0 ..< items.count {
                items[i].state = (i == newValue).stateValue
            }
        }
    }

    /// Returns all checked items.
    public var checkedItems: [String] {
        get {
            var out = [String]()
            for item in items where item.state == .on {
                out.append(item.title)
            }
            return out
        }

        set {
            for item in items {
                item.state = .off
            }
            for item in items where newValue.contains(item.title) {
                item.state = .on
            }
        }
    }

    /// Removes checked state from all items.
    public func checkNone() {
        for item in items {
            item.state = .off
        }
    }

    public func copyItems(to target: NSMenu) {
        for item in items {
            if let mitem = item.copy() as? NSMenuItem {
                target.addItem(mitem)
            }
        }
    }

    @MainActor
    public static func popUpContextMenuBeneath(
        _ menu: NSMenu,
        with event: NSEvent,
        for view: NSView
    ) {
        let localLocation = NSPoint(x: 0, y: -5)
        let windowLocation = view.convert(localLocation, to: nil)

        guard let newEvent = NSEvent.mouseEvent(
            with: event.type,
            location: windowLocation,
            modifierFlags: event.modifierFlags,
            timestamp: event.timestamp,
            windowNumber: event.windowNumber,
            context: nil,
            eventNumber: event.eventNumber,
            clickCount: 1,
            pressure: 0
        ) else {
            return
        }

        NSMenu.popUpContextMenu(
            menu,
            with: newEvent,
            for: view
        )
    }
}
#endif
