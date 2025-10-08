import AppKit

extension NSWorkspace {
    public static func showInFinder(urls: [URL]) {
        let urls = urls.filter { FileManager.default.fileExists(atPath: $0.path) }

        let directories = urls.filter { $0.isDirectory && !$0.isPackage }
        let files = urls.filter { !$0.isDirectory || $0.isPackage }

        for item in directories {
            NSWorkspace.shared.open(item)
        }

        if files.isNotEmpty {
            NSWorkspace.shared.activateFileViewerSelecting(files)
        }
    }
}
