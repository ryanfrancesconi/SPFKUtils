// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/SPFKUtils

import Foundation

/// Track the progress of 'chunklength' items by summing an array of values to one
public actor ChunkedProgressTracker {
    public var totalCompleted: ProgressValue1 {
        guard progressCompleted.count > 0 else { return 0 }
        return progressCompleted.reduce(0, +) / progressCompleted.count.double
    }

    public private(set) var progressCompleted: [ProgressValue1]

    public init(chunklength: Int) {
        progressCompleted = [Double](repeating: 0, count: chunklength)
    }

    public func update(index: Int, progress: ProgressValue1) -> ProgressValue1 {
        progressCompleted[index] = progress
        return totalCompleted
    }
}
