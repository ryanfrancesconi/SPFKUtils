// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/SPFKUtils

import AppKit

/// Generates first responder actions to assist with building main application menus programatically.
///
/// `FirstResponder.send(action: .showHelp)`
public class FirstResponder {
    /// A subset of general responder actions which are handled by this class
    public enum Action: Equatable {
        case orderFrontStandardAboutPanel
        case hide
        case openDocument
        case undo
        case redo
        case cut
        case copy
        case paste
        case pasteAsPlainText
        case delete
        case selectAll
        case deselectAll
        case selectPrevious
        case selectNext
        case performMiniaturize
        case performZoom
        case showHelp
    }

    public static func send(action: Action) {
        switch action {
        case .orderFrontStandardAboutPanel:
            send(selector: #selector(orderFrontStandardAboutPanel(_:)))
        case .openDocument:
            send(selector: #selector(openDocument(_:)))
        case .hide:
            send(selector: #selector(hide(_:)))
        case .undo:
            send(selector: #selector(undo(_:)))
        case .redo:
            send(selector: #selector(redo(_:)))
        case .cut:
            send(selector: #selector(cut(_:)))
        case .copy:
            send(selector: #selector(copy(_:)))
        case .paste:
            send(selector: #selector(paste(_:)))
        case .pasteAsPlainText:
            send(selector: #selector(pasteAsPlainText(_:)))
        case .delete:
            send(selector: #selector(delete(_:)))
        case .selectAll:
            send(selector: #selector(selectAll(_:)))
        case .deselectAll:
            send(selector: #selector(deselectAll(_:)))
        case .selectPrevious:
            send(selector: #selector(selectPrevious(_:)))
        case .selectNext:
            send(selector: #selector(selectNext(_:)))
        case .performMiniaturize:
            send(selector: #selector(performMiniaturize(_:)))
        case .performZoom:
            send(selector: #selector(performZoom(_:)))
        case .showHelp:
            send(selector: #selector(showHelp(_:)))
        }
    }

    private static func send(selector: Selector) {
        NSApp.sendAction(selector, to: nil, from: self)
    }
}

// MARK: - Function Definitions

// These do nothing other than provide a signature to send out to the responder chain
extension FirstResponder {
    // MARK: - App

    @objc static func orderFrontStandardAboutPanel(_ sender: Any) {}
    @objc static func hide(_ sender: Any) {}
    @objc static func terminate(_ sender: Any) {}

    // MARK: - File

    @objc static func openDocument(_ sender: Any) {}

    // MARK: - Edit

    @objc static func undo(_ sender: Any) {}
    @objc static func redo(_ sender: Any) {}
    @objc static func cut(_ sender: Any) {}
    @objc static func copy(_ sender: Any) {}
    @objc static func paste(_ sender: Any) {}
    @objc static func pasteAsPlainText(_ sender: Any) {}
    @objc static func delete(_ sender: Any) {}
    @objc static func selectAll(_ sender: Any) {}
    @objc static func deselectAll(_ sender: Any) {}
    @objc static func selectPrevious(_ sender: Any) {}
    @objc static func selectNext(_ sender: Any) {}

    // MARK: - View

    // MARK: - Window

    @objc static func performMiniaturize(_ sender: Any) {}
    @objc static func performZoom(_ sender: Any) {}

    // MARK: - Help

    @objc static func showHelp(_ sender: Any) {}
}
