
import Foundation

extension Bool {
    /// Returns a string representation of a Bool, useful for XML attributes
    /// returns "true"'" or "false"
    @inlinable public var string: String {
        String(self)
    }
}
