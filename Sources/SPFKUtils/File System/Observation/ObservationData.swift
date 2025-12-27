// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-utils

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
    import Foundation
    import SPFKBase

    actor ObservationData {
        var observers = Set<DirectoryObserver>()

        var observedDirectories: Set<URL> {
            Set<URL>(observers.map(\.url))
        }

        var isObserving: Bool { observers.isNotEmpty }

        private var eventQueue: Set<DirectoryEvent> = .init()
        private var eventTask: Task<Void, Error>?

        var delegate: DirectoryEnumerationObserverDelegate?

        let url: URL

        init(url: URL) throws {
            guard url.isDirectory else {
                throw NSError(description: "URL must be a directory")
            }

            self.url = url
        }

        func update(delegate: DirectoryEnumerationObserverDelegate?) {
            self.delegate = delegate
        }
    }

    extension ObservationData {
        func start() async throws {
            let allDirectories = Set<URL>([url] + FileSystem.getDirectories(in: url, recursive: true))

            try await startFileObservation(for: allDirectories)
        }

        private func startFileObservation(for urls: Set<URL>) async throws {
            for url in urls where url.isDirectory {
                let observer = try DirectoryObserver(url: url)
                observer.delegate = self
                try observer.start()

                insert(observer)
            }
        }

        func stop() {
            for observer in observers {
                observer.stop()
                observer.delegate = nil
            }

            observers.removeAll()
            disposeQueue()
        }

        private func disposeQueue() {
            eventQueue.removeAll()
            eventTask?.cancel()
            eventTask = nil
        }
    }

    // MARK: - Event Handlers

    extension ObservationData: DirectoryObserverDelegate {
        func handleObservation(event: DirectoryEvent) async {
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
                    remove(urls: urls)
                }
            }

            await queue(event: event)
        }
    }

    extension ObservationData {
        private func insert(_ observer: DirectoryObserver) {
            observers.insert(observer)
        }

        private func remove(urls: Set<URL>) {
            for observer in observers {
                if urls.contains(observer.url) {
                    observer.stop()
                    observer.delegate = nil
                }
            }

            observers = observers.filter {
                $0.delegate != nil
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

                try await delegate?.directoryUpdated(events: eventQueue)

                await disposeQueue()
            }
        }
    }
#endif
