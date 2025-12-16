import Foundation
import XAttr

extension URL {
    public func setExtendedAttributeAndModify(name: String, value: Data, options: XAttrOptions = []) throws {
        try setExtendedAttribute(
            name: name,
            value: value,
            options: options
        )

        try updateModificationDate()
    }

    public func updateModificationDate(_ now: Date = .init()) throws {
        try FileManager.default.setAttributes(
            [.modificationDate: now],
            ofItemAtPath: path
        )
    }
}
