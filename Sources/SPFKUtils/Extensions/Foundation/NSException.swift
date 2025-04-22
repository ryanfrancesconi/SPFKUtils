// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/SPFKUtils

import Foundation

extension NSException {
    public var error: NSError {
        NSError(
            domain: "com.spongefork.exception",
            code: 1,
            userInfo: userInfo as? [String: Any]
        )
    }
}
