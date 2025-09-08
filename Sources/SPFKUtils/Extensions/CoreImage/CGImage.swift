// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/SPFKUtils

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

        let bytesPerPixel = self.bitsPerPixel / self.bitsPerComponent
        let destBytesPerRow = width * bytesPerPixel

        guard let colorSpace = self.colorSpace else { return nil }

        guard let context = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: self.bitsPerComponent,
            bytesPerRow: destBytesPerRow,
            space: colorSpace,
            bitmapInfo: self.alphaInfo.rawValue
        ) else { return nil }

        context.interpolationQuality = .high
        
        context.draw(
            self,
            in: CGRect(x: 0, y: 0, width: width, height: height)
        )

        return context.makeImage()
    }
}
