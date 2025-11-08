import AppKit
import CoreGraphics
import Foundation
import SPFKTesting
@testable import SPFKUtils
import Testing
import UniformTypeIdentifiers

class CGImageTests {
    @Test func cgImageDataRoundtrip() async throws {
        let url = TestBundleResources.shared.sharksandwich

        let originalImage = try #require(NSImage(contentsOf: url)?.cgImage)
        Log.debug(originalImage)

        let data = try #require(originalImage.jpegRepresentation)
        let newImage = try #require(NSImage(data: data)?.cgImage)

        Log.debug(newImage)

        #expect(newImage.width == originalImage.width)
        #expect(newImage.height == originalImage.height)
        #expect(newImage.colorSpace == originalImage.colorSpace)
        #expect(newImage.utType == originalImage.utType)
        #expect(newImage.bytesPerRow == originalImage.bytesPerRow)
        #expect(newImage.bitsPerPixel == originalImage.bitsPerPixel)
        #expect(newImage.bitsPerComponent == originalImage.bitsPerComponent)
        #expect(newImage.alphaInfo == originalImage.alphaInfo)
    }
}
