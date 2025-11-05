import AppKit
import CoreGraphics
import Foundation
import SPFKTesting
@testable import SPFKUtils
import Testing
import UniformTypeIdentifiers

class CGImageTests {
    @Test func cgImageDataRoundtrip() async throws {
        let url = TestBundleResources.shared.cowbell_wav
        let cgImage = try #require(url.finderIcon?.cgImage)
        Log.debug(cgImage)

        let data = try cgImage.dataRepresentation(utType: .png)
        Log.debug(data)
        
        let newImage = NSImage(data: data)?.cgImage
        Log.debug(newImage)

        #expect(newImage == cgImage)
    }
}
