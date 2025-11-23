#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit

@MainActor
extension NSAppearance {
    public static let dark = NSAppearance(named: .darkAqua)
}
#endif
