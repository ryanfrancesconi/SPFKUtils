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

extension NSRect {
    public init?(xml: AEXMLElement) {
        guard let x = xml.attributes["x"]?.cgFloat,
              let y = xml.attributes["y"]?.cgFloat,
              let width = xml.attributes["width"]?.cgFloat,
              let height = xml.attributes["height"]?.cgFloat
        else { return nil }

        self = NSRect(x: x, y: y, width: width, height: height)
    }

    public init(size: NSSize) {
        self = NSRect(origin: .zero, size: size)
    }

    public init(width: CGFloat, height: CGFloat) {
        self = NSRect(x: 0, y: 0, width: width, height: height)
    }

    public func toXML() -> AEXMLElement {
        let attributes = [
            "x": String(describing: origin.x),
            "y": String(describing: origin.y),
            "width": String(describing: size.width),
            "height": String(describing: size.height),
        ]
        let out = AEXMLElement(name: "frame", attributes: attributes)
        return out
    }
}

extension NSSize {
    public init?(xml: AEXMLElement) {
        guard let width = xml.attributes["width"]?.cgFloat,
              let height = xml.attributes["height"]?.cgFloat
        else { return nil }

        self = NSSize(width: width, height: height)
    }

    public func toXML() -> AEXMLElement {
        let attributes = [
            "width": String(describing: width),
            "height": String(describing: height),
        ]
        let out = AEXMLElement(name: "size", attributes: attributes)
        return out
    }
}
