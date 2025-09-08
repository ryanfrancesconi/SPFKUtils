import AppKit

extension NSDraggingInfo {
    public func toFileURLs() throws -> [URL] {
        guard let items = draggingPasteboard.pasteboardItems, items.isNotEmpty,
              let types = draggingPasteboard.types else {
            throw NSError(description: "pasteboardItems is empty")
        }

        var urls = [URL]()

        for item in items {
            guard let type = item.availableType(from: types) else {
                Log.error("Failed to determine type for", item)
                continue
            }

            guard type == .fileURL else {
                Log.error("Not a fileURL")
                continue
            }

            if let value = item.string(forType: type),
               let url = URL(string: value) {
                urls.append(url)
            }
        }

        Log.debug(urls)

        guard urls.isNotEmpty else {
            throw NSError(description: "No files were found")
        }

        return urls
    }
}
