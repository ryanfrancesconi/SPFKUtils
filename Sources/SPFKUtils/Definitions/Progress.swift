
import Foundation

/// Indicates a range of 0 ... 1
public typealias ProgressValue1 = Double

/// Indicates a range of 0 ... 100
public typealias ProgressValue100 = Double

public typealias AsyncProgressEvent = (string: String?, progress: ProgressValue100)

public protocol AsyncProgressDelegate {
    func asyncProgress(event: AsyncProgressEvent) async
}

//

public actor LoadProgress {
    var loaded: Int = 0
    var total: Int = 0

    public private(set) var progress: ProgressValue1 = 0

    public init(total: Int) {
        self.total = total
    }

    public func increment() {
        loaded += 1
        guard total != 0 else { return }

        progress = ProgressValue1(loaded) / ProgressValue1(total)
    }
}
