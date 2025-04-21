import Foundation
import SPFKTesting
import SPFKUtils
import Testing

@Suite(.serialized)
class BundleResourcesTests: BinTestCase {
    @Test func testBin() async throws {
        let tmpfile = try copyToBin(url: BundleResources.shared.wav_bext_v2)

        #expect(FileManager.default.fileExists(atPath: tmpfile.path))
    }

    @Test func testBundle() async throws {
        let bundle = BundleResources.shared

        Swift.print(bundle.bundleURL)
    }
}
