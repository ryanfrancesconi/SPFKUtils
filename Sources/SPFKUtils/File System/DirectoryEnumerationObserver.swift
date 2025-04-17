import Foundation

/// Observe this directory url and all its subdirectory children by sending a common event.
///
/// Be careful with this class and only establish on known directories as it will perform
/// a deep enumeration.
public class DirectoryEnumerationObserver {
    public private(set) var url: URL

    public weak var delegate: DirectoryEnumerationObserverDelegate?

    private var observers = [DirectoryObserver]()

    private var observedDirectories: [URL] {
        observers.map { $0.url }
    }

    public var isObserving: Bool { observers.isNotEmpty }

    var eventQueue: [DirectoryEvent] = .init()

    public init(url: URL) throws {
        guard url.isDirectory else {
            throw NSError(description: "URL must be a directory")
        }

        self.url = url
    }

    deinit {
        stop()
        delegate = nil
        // Log.debug("* { \(description) }")
    }

    public func start() async throws {
        guard !isObserving else { return }

        stop()

        await collectChildDirectoriesAndStartObservation()
    }

    public func stop() {
        guard isObserving else { return }

        stopAllFileObservation()
    }

    private func collectChildDirectoriesAndStartObservation() async {
        let allDirectories = [url] + FileSystem.getDirectories(in: url, recursive: true)

        do {
            try startFileObservation(for: allDirectories)
        } catch {
            Log.error(error)
        }
    }

    private func startFileObservation(for urls: [URL]) throws {
        for url in urls where url.isDirectory {
            let observer = try DirectoryObserver(url: url)

            // can just forward this event
            observer.eventHandler = { [weak self] in self?.handleObservation(event: $0) }
            try observer.start()

            observers.append(observer)
        }
    }

    private func stopFileObservation(for urls: [URL]) {
        observers.forEach {
            if urls.contains($0.url) {
                $0.stop()
                $0.eventHandler = nil
            }
        }

        observers = observers.filter {
            $0.eventHandler != nil
        }
    }

    private func stopAllFileObservation() {
        observers.forEach {
            $0.stop()
            $0.eventHandler = nil
        }

        observers.removeAll()
    }

    var eventTask: Task<Void, Error>?

    func queue(event: DirectoryEvent) {
        if !eventQueue.contains(event) {
            eventQueue.append(event)
        }

        eventTask?.cancel()
        eventTask = Task {
            try await Task.sleep(seconds: 1)

            guard !Task.isCancelled else {
                Log.error("XXX")
                return
            }

            try await self.delegate?.directoryUpdated(events: self.eventQueue)
            self.eventQueue.removeAll()
        }
    }
}

extension DirectoryEnumerationObserver: CustomStringConvertible {
    public var description: String {
        "DirectoryEnumerationObserver(url: \"\(url.path)\")"
    }
}

// MARK: - Event Handlers

extension DirectoryEnumerationObserver {
    func handleObservation(event: DirectoryEvent) {
        switch event {
        case let .new(files: urls, source: source):

            Log.debug("new", "source:", source, "urls", urls)

            if source == url {
                do {
                    try startFileObservation(for: urls)
                } catch {
                    Log.error(error)
                }
            }

        case let .removed(files: urls, source: source):
            Log.debug("removed", "source:", source, "urls", urls)

            if source == url {
                stopFileObservation(for: urls)
            }
        }

        queue(event: event)
    }
}

public protocol DirectoryEnumerationObserverDelegate: AnyObject {
    func directoryUpdated(events: [DirectoryEvent]) async throws
}
