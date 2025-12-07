// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-utils

import Foundation

extension UndoManager {
    public func registerUndo<TargetType>(
        named name: String,
        withTarget target: TargetType,
        handler: @escaping (TargetType) -> Void
    ) where TargetType: AnyObject {
        registerUndo(withTarget: target, handler: handler)
        setActionName(name)
    }
}
