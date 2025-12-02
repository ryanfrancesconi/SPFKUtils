// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/SPFKUtils

import Foundation

actor ObservationData {
    var observers = Set<DirectoryObserver>()

    var observedDirectories: Set<URL> {
        Set<URL>(observers.map(\.url))
    }

    var isObserving: Bool { observers.isNotEmpty }

    private var eventQueue: Set<DirectoryEvent> = .init()
    var eventTask: Task<Void, Error>?

    var delegate: DirectoryEnumerationObserverDelegate?

    func update(delegate: DirectoryEnumerationObserverDelegate) {
        self.delegate = delegate
    }

    func insert(_ observer: DirectoryObserver) {
        observers.insert(observer)
    }

    func remove(urls: Set<URL>) {
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

    func removeAll() {
        for observer in observers {
            observer.stop()
            observer.delegate = nil
        }

        observers.removeAll()

        disposeQueue()
    }

    func disposeQueue() {
        eventQueue.removeAll()
        eventTask?.cancel()
        eventTask = nil
    }

    func queue(event: DirectoryEvent) {
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
