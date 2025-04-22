// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/SPFKUtils

import Foundation

extension UndoManager {
    public func registerUndo<TargetType>(
        named name: String? = nil,
        withTarget target: TargetType,
        handler: @escaping (TargetType) -> Void
    ) where TargetType: AnyObject {
        registerUndo(withTarget: target, handler: handler)

        if let name {
            setActionName(name)
        }
    }
}
