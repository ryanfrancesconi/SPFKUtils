import Foundation

public class DirectoryObserver {
    static let retryCount: Int = 3
    static let pollInterval: TimeInterval = 1

    private var source: DispatchSourceFileSystemObject?
    private var previousContents: Set<URL>?
    private var queue: DispatchQueue?
    private var retriesLeft: Int = 0
    private var directoryChanged = false

    public var isWatching: Bool { source != nil }

    public var eventHandler: ((DirectoryEvent) -> Void)?

    public private(set) var url: URL

    public init(url: URL) throws {
        guard url.isDirectory else {
            throw NSError(description: "URL must be a directory")
        }

        self.url = url
        previousContents = contents(of: url)
    }

    deinit {
        stop()
        eventHandler = nil
        // Log.debug("* { \(description) }")
    }

    public func start() throws {
        guard !isWatching else { return }

        // descriptor requested for event notifications only
        let descriptor = open(url.path, O_EVTONLY)

        guard descriptor != -1 else {
            throw NSError(description: "failed to open url: \(url.path)")
        }

        queue = DispatchQueue.global(qos: .default)

        source = DispatchSource.makeFileSystemObjectSource(
            fileDescriptor: descriptor,
            eventMask: [.write, .delete, .rename], // actions to monitor
            queue: queue
        )

        source?.setEventHandler { [weak self] in
            self?.directoryDidChange()
        }

        source?.setCancelHandler {
            close(descriptor)
        }

        source?.resume()
    }

    public func stop() {
        guard isWatching else { return }
        source?.cancel()
        source?.setEventHandler(handler: nil)
        source?.setCancelHandler(handler: nil)
        source = nil
    }
}

extension DirectoryObserver: CustomStringConvertible {
    public var description: String {
        "DirectoryObserver(url: \"\(url.path)\")"
    }
}

// MARK: - Private methods

extension DirectoryObserver {
    private func directoryDidChange() {
        guard !directoryChanged else { return }

        directoryChanged = true
        retriesLeft = DirectoryObserver.retryCount
        checkChanges(after: DirectoryObserver.pollInterval)
    }

    private func contents(of url: URL) -> Set<URL> {
        let urls = (try? FileManager.default.contentsOfDirectory(
            at: url,
            includingPropertiesForKeys: [.isDirectoryKey],
            options: .skipsHiddenFiles
        )) ?? []

        return Set(urls)
    }

    private func directoryMetadata(url: URL) throws -> [String] {
        let contents = try FileManager.default.contentsOfDirectory(atPath: url.path)

        var directoryMetadata = [String]()

        for filename in contents {
            let fileUrl = url.appendingPathComponent(filename)

            guard let fileSize = fileUrl.fileSize else {
                continue
            }

            let sizeString = fileSize.string
            let fileHash = filename + sizeString

            directoryMetadata.append(fileHash)
        }

        return directoryMetadata
    }

    private func checkChanges(after delay: TimeInterval) {
        guard let directoryMetadata = try? directoryMetadata(url: url),
              let queue else {
            return
        }

        let time = DispatchTime.now() + delay

        queue.asyncAfter(deadline: time) { [weak self] in
            self?.pollDirectoryForChangesWith(directoryMetadata)
        }
    }

    private func pollDirectoryForChangesWith(_ oldMetadata: [String]) {
        guard let newDirectoryMetadata = try? directoryMetadata(url: url) else {
            return
        }

        directoryChanged = newDirectoryMetadata != oldMetadata

        retriesLeft = directoryChanged
            ? DirectoryObserver.retryCount
            : retriesLeft

        retriesLeft = retriesLeft - 1

        if directoryChanged || 0 < retriesLeft {
            // Either the directory is changing or
            // we should try again as more changes may occur
            checkChanges(after: DirectoryObserver.pollInterval)

        } else {
            // Changes appear to be completed
            // Post a notification informing that the directory did change
            try? postNotification()
        }
    }

    private func postNotification() throws {
        guard let previousContents else { return }

        let newContents = contents(of: url)

        let newElements = newContents.subtracting(previousContents)
        let deletedElements = previousContents.subtracting(newContents)

        self.previousContents = newContents

        if !deletedElements.isEmpty {
            eventHandler?(.removed(files: Array(deletedElements), source: url))
        }

        if !newElements.isEmpty {
            eventHandler?(.new(files: Array(newElements), source: url))
        }
    }
}
