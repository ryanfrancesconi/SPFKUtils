// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-utils

import CoreGraphics
import CoreImage
import Foundation
import UniformTypeIdentifiers

extension CGImage {
    public enum ExportType: String {
        case png
        case jpeg
        case heif
        case tiff

        public var utType: UTType {
            switch self {
            case .png: return .png
            case .jpeg: return .jpeg
            case .heif: return .heif
            case .tiff: return .tiff
            }
        }
    }

    public func export(type: ExportType, to url: URL) throws {
        let ciContext = CIContext()
        let ciImage = CIImage(cgImage: self)

        guard let colorSpace = ciImage.colorSpace else {
            throw NSError(description: "Invalid colorSpace in returned CIImage")
        }

        switch type {
        case .png:
            try ciContext.writePNGRepresentation(of: ciImage, to: url, format: .RGBA8, colorSpace: colorSpace)

        case .jpeg:
            try ciContext.writeJPEGRepresentation(of: ciImage, to: url, colorSpace: colorSpace)

        case .heif:
            try ciContext.writeHEIFRepresentation(of: ciImage, to: url, format: .RGBA8, colorSpace: colorSpace)

        case .tiff:
            try ciContext.writeTIFFRepresentation(of: ciImage, to: url, format: .RGBA8, colorSpace: colorSpace)
        }
    }

    public func scaled(to size: CGSize) -> CGImage? {
        let width: Int = Int(size.width)
        let height: Int = Int(size.height)

        var binfo = bitmapInfo
        binfo.pixelFormat = .packed
        binfo.byteOrder = .orderDefault
        binfo.alpha = .premultipliedLast

        guard let context = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: bitsPerComponent,
            bytesPerRow: bytesPerRow,
            space: colorSpace,
            bitmapInfo: binfo
        ) else {
            return nil
        }

        context.interpolationQuality = .high

        context.draw(
            self,
            in: CGRect(x: 0, y: 0, width: width, height: height)
        )

        return context.makeImage()
    }
}

extension CGImage {
    public var jpegRepresentation: Data? {
        try? dataRepresentation(utType: .jpeg)
    }

    public var pngRepresentation: Data? {
        try? dataRepresentation(utType: .png)
    }

    /// Generate data for the image in the format defined by utType.
    /// - Parameters:
    ///   - utType: The UTType for the image to generate
    ///   - dpi: The image's dpi
    ///   - compression: The compression level to apply (0...1)
    ///   - excludeGPSData: If true, strips any GPS information from the output
    ///   - otherOptions: Other options as defined in [documentation](https://developer.apple.com/documentation/imageio/cgimagedestination)
    /// - Returns: image data
    public func dataRepresentation(
        utType: UTType,
        dpi: CGFloat = 72,
        compression: CGFloat? = nil,
        excludeGPSData: Bool = false,
        otherOptions: [String: Any]? = nil
    ) throws -> Data {
        // Make sure that the DPI level is at least somewhat sane
        guard dpi >= 0 else {
            throw NSError(description: "invalid DPI \(dpi)")
        }

        var options: [CFString: Any] = [
            kCGImagePropertyPixelWidth: self.width,
            kCGImagePropertyPixelHeight: self.height,
            kCGImagePropertyDPIWidth: dpi,
            kCGImagePropertyDPIHeight: dpi,
        ]

        if utType == .jpeg, let compression {
            options[kCGImageDestinationLossyCompressionQuality] = compression.clamped(to: 0 ... 1)
        }

        if excludeGPSData == true {
            options[kCGImageMetadataShouldExcludeGPS] = true
        }

        // Add in the user's customizations
        otherOptions?.forEach {
            options[$0.0 as CFString] = $0.1
        }

        let uniformTypeIdentifier = utType.identifier as CFString

        guard
            let mutableData = CFDataCreateMutable(nil, 0),
            let destination = CGImageDestinationCreateWithData(mutableData, uniformTypeIdentifier, 1, nil)
        else {
            throw NSError(description: "CGImageDestinationCreateWithData")
        }

        CGImageDestinationAddImage(destination, self, options as CFDictionary)
        CGImageDestinationFinalize(destination)

        let resultData = mutableData as Data

        if resultData.count == 0 {
            throw NSError(description: "resultData.count == 0")
        }

        return resultData
    }

    public static func createJPEG(from data: Data) throws -> CGImage {
        guard let dataProvider = CGDataProvider(data: data as CFData) else {
            throw NSError(description: "Failed to create CGDataProvider")
        }

        guard let cgImage = CGImage(
            jpegDataProviderSource: dataProvider,
            decode: nil,
            shouldInterpolate: false,
            intent: .defaultIntent
        ) else {
            throw NSError(description: "Failed to create CGImage")
        }

        return cgImage
    }
}
