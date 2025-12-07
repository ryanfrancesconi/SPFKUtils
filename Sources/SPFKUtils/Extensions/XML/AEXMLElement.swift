// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-utils

import AEXML
import Foundation

extension AEXMLElement {
    public func firstChild(named name: String) -> AEXMLElement? {
        self[name].first
    }

    /// Convenience to write this element as it's own XML file to disk
    /// - Parameter url: URL to write to
    public func write(to url: URL) throws {
        // adds XML header
        let doc = AEXMLDocument(root: self)

        // write string version
        try doc.xml.write(to: url, atomically: false, encoding: .utf8)
    }

    // Used to return nil for value in cases where it is defined but empty
    public func attribute(named name: String) -> String? {
        guard let string = attributes[name],
              string != "" else {
            return nil
        }
        return string
    }
}
