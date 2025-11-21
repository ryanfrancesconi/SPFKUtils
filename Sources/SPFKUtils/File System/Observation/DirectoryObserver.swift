// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/SPFKUtils

import Dispatch
import Foundation

extension DirectoryObserver: Equatable {
    public static func == (lhs: DirectoryObserver, rhs: DirectoryObserver) -> Bool {
        lhs.url == rhs.url
    }
}

extension DirectoryObserver: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(url)
    }
}

extension DirectoryObserver: CustomStringConvertible {
    public var description: String {
        "DirectoryObserver(url: \"\(url.path)\")"
    }
}

public final class DirectoryObserver: @unchecked Sendable {
    static let retryCount: Int = 3
    static let pollInterval: TimeInterval = 0.5

    private var source: DispatchSourceFileSystemObject?
    private var queue: DispatchQueue?
    private var retriesLeft: Int = 0
    private var directoryChanged = false
    private var previousContents: Set<URL>?

    public weak var delegate: DirectoryObserverDelegate?

    public let url: URL
    public let eventMask: DispatchSource.FileSystemEvent

    var eventTask: Task<Void, Error>?

    public var isWatching: Bool { source != nil }

    public init(url: URL, eventMask: DispatchSource.FileSystemEvent = [.write, .delete, .rename]) throws {
        guard url.isDirectory else {
            throw NSError(description: "URL must be a directory")
        }

        self.url = url
        self.eventMask = eventMask

        previousContents = contents(of: url)
    }

    deinit {
        stop()
    }

    public func start() throws {
        guard !isWatching else { return }

        // descriptor requested for event notifications only
        let descriptor = open(url.path, O_EVTONLY)

        guard descriptor != -1 else {
            throw NSError(description: "failed to open url: \(url.path)")
        }

        queue = DispatchQueue.global(qos: .background)

        source = DispatchSource.makeFileSystemObjectSource(
            fileDescriptor: descriptor,
            eventMask: eventMask, // actions to monitor
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
            eventTask?.cancel()
            eventTask = Task {
                try Task.checkCancellation()
                try await postNotification()
            }
        }
    }

    private func postNotification() async throws {
        guard let previousContents else { return }

        let newContents = contents(of: url)

        let newElements = newContents.subtracting(previousContents)
        let deletedElements = previousContents.subtracting(newContents)

        self.previousContents = newContents

        if !deletedElements.isEmpty {
            await delegate?.handleObservation(event:
                .removed(files: deletedElements, source: url)
            )
        }

        if !newElements.isEmpty {
            await delegate?.handleObservation(event:
                .new(files: newElements, source: url)
            )
        }
    }
}
