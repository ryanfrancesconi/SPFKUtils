
#if canImport(AppKit) && !targetEnvironment(macCatalyst)
    import AppKit
    import CoreGraphics

    public struct HexColor: Hashable, Codable, Sendable {
        public private(set) var hexString: String

        public var nsColor: NSColor? {
            guard let rgba = try? RGBAColor(hexString: hexString) else { return nil }
            return NSColor(red: rgba.r, green: rgba.g, blue: rgba.b, alpha: rgba.a)
        }

        public init?(nsColor: NSColor) {
            guard let string = nsColor.toHex() else { return nil }
            self = HexColor(hexString: string)
        }

        public init(hexString: String) {
            self.hexString = hexString
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let value = try container.decode(String.self)

            self.init(hexString: value)
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            try container.encode(hexString)
        }
    }
#endif // canImport(AppKit)
