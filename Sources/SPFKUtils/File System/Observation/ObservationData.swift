// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/SPFKUtils

import Foundation

public actor ObservationData {
    var observers = Set<DirectoryObserver>()

    var observedDirectories: Set<URL> {
        Set<URL>(observers.map { $0.url })
    }

    public var isObserving: Bool { observers.isNotEmpty }

    init() {}

    public func insert(_ observer: DirectoryObserver) {
        observers.insert(observer)
    }

    public func remove(urls: Set<URL>) {
        observers.forEach {
            if urls.contains($0.url) {
                $0.stop()
                $0.delegate = nil
            }
        }

        observers = observers.filter {
            $0.delegate != nil
        }
    }

    public func removeAll() {
        observers.forEach {
            $0.stop()
            $0.delegate = nil
        }

        observers.removeAll()
    }
}
