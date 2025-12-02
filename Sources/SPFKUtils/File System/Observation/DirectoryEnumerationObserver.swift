// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/SPFKUtils

#if os(macOS)
    import Foundation
    import SPFKBase

    /// Observe this directory url and all its subdirectory children by sending a common event.
    ///
    /// Be careful with this class and only establish on known directories as it will perform
    /// a deep enumeration.
    public final class DirectoryEnumerationObserver: Sendable {
        public let url: URL
        public let delegate: DirectoryEnumerationObserverDelegate
        let storage: ObservationData = ObservationData()

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
            guard await !storage.isObserving else { return }

            await storage.update(delegate: self)
            await stop()
            try await collectChildDirectoriesAndStartObservation()
        }

        public func stop() async {
            guard await storage.isObserving else { return }
            await storage.removeAll()
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

                await storage.insert(observer)
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
                    await storage.remove(urls: urls)
                }
            }

            await storage.queue(event: event)
        }
    }

    extension DirectoryEnumerationObserver: DirectoryEnumerationObserverDelegate {
        public func directoryUpdated(events: Set<DirectoryEvent>) async throws {
            try await delegate.directoryUpdated(events: events)
        }
    }

#endif
