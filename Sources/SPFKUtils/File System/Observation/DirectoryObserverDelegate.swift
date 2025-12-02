// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/SPFKUtils

import Foundation

protocol DirectoryObserverDelegate: AnyObject {
    func handleObservation(event: DirectoryEvent) async
}
