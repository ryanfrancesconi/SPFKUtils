// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/SPFKUtils

#if os(macOS)
    import Foundation

    /// Observe this directory url and all its subdirectory children by sending a common event.
    ///
    /// Be careful with this class and only establish on known directories as it will perform
    /// a deep enumeration.
    public final class DirectoryEnumerationObserver: @unchecked Sendable {
        public let url: URL
        public let delegate: DirectoryEnumerationObserverDelegate

        public let observers = ObservationData()

        private var eventQueue: Set<DirectoryEvent> = .init()

        var eventTask: Task<Void, Error>?

        public init(url: URL, delegate: DirectoryEnumerationObserverDelegate) throws {
            guard url.isDirectory else {
                throw NSError(description: "URL must be a directory")
            }

            self.url = url
            self.delegate = delegate
        }

        deinit {
            Log.debug("- { \(self) }")
        }

        public func start() async throws {
            guard await !observers.isObserving else { return }

            await stop()
            try await collectChildDirectoriesAndStartObservation()
        }

        public func stop() async {
            guard await observers.isObserving else { return }
            await observers.removeAll()
            eventQueue.removeAll()
            eventTask?.cancel()
            eventTask = nil
        }

        private func collectChildDirectoriesAndStartObservation() async throws {
            let allDirectories = Set<URL>([url] + FileSystem.getDirectories(in: url, recursive: true))

            try await startFileObservation(for: allDirectories)
        }

        private func startFileObservation(for urls: Set<URL>) async throws {
            for url in urls where url.isDirectory {
                let observer = try DirectoryObserver(url: url)
                observer.delegate = self
                try observer.start()

                await observers.insert(observer)
            }
        }

        private func queue(event: DirectoryEvent) async {
            if !eventQueue.contains(event) {
                eventQueue.insert(event)
            }

            eventTask?.cancel()
            eventTask = Task { [weak self] in
                guard let self else { return }

                try await Task.sleep(seconds: 1)
                try Task.checkCancellation()

                try await self.delegate.directoryUpdated(events: self.eventQueue)
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

    extension DirectoryEnumerationObserver: DirectoryObserverDelegate {
        public func handleObservation(event: DirectoryEvent) async {
            switch event {
            case let .new(files: urls, source: source):

                Log.debug("new", "source:", source, "urls", urls)

                if source == url {
                    do {
                        try await startFileObservation(for: urls)
                    } catch {
                        Log.error(error)
                    }
                }

            case let .removed(files: urls, source: source):
                Log.debug("removed", "source:", source, "urls", urls)

                if source == url {
                    await observers.remove(urls: urls)
                }
            }

            await queue(event: event)
        }
    }
#endif
