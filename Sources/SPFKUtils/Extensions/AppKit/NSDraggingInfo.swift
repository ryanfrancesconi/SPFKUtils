import AppKit

extension NSDraggingInfo {
    @MainActor
    public func toFileURLs() throws -> [URL] {
        guard let items = draggingPasteboard.pasteboardItems,
              items.isNotEmpty,
              let types = draggingPasteboard.types else {
            throw NSError(description: "pasteboardItems is empty")
        }

        var urls = [URL]()

        for item in items {
            guard let type = item.availableType(from: types) else {
                Log.error("Failed to determine type for", item)
                continue
            }

            guard let url = convertToURL(type: type, item: item) else {
                Log.error("Failed to parse URL from \(type)")

                continue
            }

            urls.append(url)
        }

        guard urls.isNotEmpty else {
            throw NSError(description: "No files were found")
        }

        return urls
    }

    private func convertToURL(type: NSPasteboard.PasteboardType, item: NSPasteboardItem) -> URL? {
        guard type == .fileURL else {
            return nil
        }

        guard let stringValue = item.string(forType: type) else {
            Log.error("failed to convert", type, "to string")
            return nil
        }

        guard let url = URL(string: stringValue), url.exists else {
            return nil
        }

        return url
    }
}
