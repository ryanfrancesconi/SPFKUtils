import Foundation

public protocol TypeDescribable {}

extension TypeDescribable {
    /// returns the name of the object, similar to obj-c className
    public var typeName: String {
        return String(describing: type(of: self))
    }

    public static var typeName: String {
        return String(describing: self)
    }
}
