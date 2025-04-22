// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/SPFKUtils

import AEXML
import Foundation

extension AEXMLDocument {
    public convenience init(fromPath path: String) throws {
        let url = URL(fileURLWithPath: path)
        try self.init(fromURL: url)
    }

    public convenience init(fromURL url: URL) throws {
        let string = try Data(contentsOf: url)
            .toString(using: .utf8)

        guard let string else {
            throw NSError(description: "Failed to parse url for xml")
        }

        try self.init(fromString: string)
    }

    public convenience init(fromString string: String) throws {
        var options = AEXML.AEXMLOptions()
        options.parserSettings.shouldTrimWhitespace = true

        // check for bad characters here...
        let string = string.removing(.controlCharacters)

        try self.init(xml: string,
                      encoding: .utf8,
                      options: options)
    }
}
