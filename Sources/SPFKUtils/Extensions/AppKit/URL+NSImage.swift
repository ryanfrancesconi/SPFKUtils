import AppKit

extension URL {
    @_disfavoredOverload
    public var finderIcon: NSImage? {
        guard isFileURL, exists else { return nil }

        guard let utType else {
            return NSWorkspace.shared.icon(forFile: path)
        }

        return NSWorkspace.shared.icon(for: utType)
    }
}
