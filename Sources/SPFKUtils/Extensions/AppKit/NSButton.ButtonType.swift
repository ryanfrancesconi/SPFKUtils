import AppKit

extension NSButton.ButtonType {
    public var isToggle: Bool {
        switch self {
        case .pushOnPushOff, .toggle, .switch, .onOff:
            return true

        default:
            return false
        }
    }
}
