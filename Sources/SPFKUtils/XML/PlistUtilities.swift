// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/SPFKUtils

import AEXML
import Foundation

public enum PlistUtilities {
    public static func dictionaryToPlist(dictionary: KeyValueDictionary) throws -> AEXMLDocument {
        let plist = try PropertyListSerialization.data(
            fromPropertyList: dictionary,
            format: .xml,
            options: .init()
        )

        return try AEXMLDocument(xml: plist)
    }

    public static func plistToDictionary(element: AEXMLElement) throws -> KeyValueDictionary {
        var element = element

        if element.name != "plist",
           let plist = element.firstDescendant(where: { $0.name == "plist" }) {
            element = plist
        }

        // hack for a zero length data error that the PropertyListSerialization throws
        var string = element.xmlCompact.replacingOccurrences(of: "<data />", with: "<data></data>")

        // remove line breaks if escaped and present
        string = string.replacingOccurrences(of: "&#10;", with: "")
        string = string.replacingOccurrences(of: "\t", with: "")

        guard let data = string.toData(using: .utf8) else {
            throw NSError(description: "Failed to convert string to data")
        }

        var format: PropertyListSerialization.PropertyListFormat = .xml

        guard let dict = try PropertyListSerialization.propertyList(
            from: data,
            options: .mutableContainersAndLeaves,
            format: &format
        ) as? KeyValueDictionary else {
            throw NSError(description: "Failed to convert propertyList to KeyValueDictionary")
        }

        return dict
    }

    /// Replaces deprecated NSDictionary(contentsOf: URL)
    public static func dictionary(from url: URL) throws -> KeyValueDictionary {
        let doc = try AEXMLDocument(fromURL: url)
        return try plistToDictionary(element: doc.root)
    }
}
