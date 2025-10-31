// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/SPFKUtils

import Foundation

extension NSError {
    public convenience init(
        description: String,
        domain: String = Bundle.main.bundleIdentifier ?? "SPFKUtils",
        code: Int = 1
    ) {
        let userInfo: [String: Any] = [
            NSLocalizedDescriptionKey: description,
        ]

        self.init(
            domain: domain,
            code: code,
            userInfo: userInfo
        )
    }
}
