
import Foundation

/// Test case base to be used for Swift Testing where temp media files are needed.
/// All functionality is in `TestCaseModel`.
open class BinTestCase: TestCaseModel {
    /// Temp files will be written here
    public private(set) lazy var bin: URL = createBin()

    /// in cases where you want to check the actual files after the test completes
    /// can set this to false to leave in temp
    public var deleteBinOnExit = true

    public init() {}

    deinit {
        guard deleteBinOnExit, bin != defaultURL else { return }
        removeBin()
    }
}
