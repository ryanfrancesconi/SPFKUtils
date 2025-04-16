// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/SPFKUtils

import Foundation

public protocol Serializable: Codable {
    init(data: Data) throws
}

extension Serializable {
    public var dataRepresentation: Data? {
        do {
            return try PropertyListEncoder().encode(self)
        } catch {
            Log.error(error)
        }
        return nil
    }

    public var plistRepresentation: String? {
        let encoder = PropertyListEncoder()
        encoder.outputFormat = .xml

        guard let data = try? encoder.encode(self) else {
            return nil
        }

        return String(data: data, encoding: .utf8)
    }

    public var base64EncodedString: String? {
        dataRepresentation?.base64EncodedString()
    }

    public init(base64EncodedString: String) throws {
        guard let data = Data(base64Encoded: base64EncodedString) else {
            throw NSError(
                domain: Bundle.main.bundleIdentifier ?? "",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: "Failed to parse string"]
            )
        }

        try self.init(data: data)
    }
}
