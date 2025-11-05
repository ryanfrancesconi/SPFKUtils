import AppKit

extension URL {
    @_disfavoredOverload
    public var finderIcon: NSImage? {
        guard isFileURL, exists else { return nil }

        return NSWorkspace.shared.icon(forFile: path)
    }

    @_disfavoredOverload
    public var contentTypeIcon: NSImage? {
        guard isFileURL, exists, let utType else { return nil }

        return NSWorkspace.shared.icon(for: utType)
    }
}
