// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/SPFKUtils

import Foundation

extension DispatchQueue {
    /// Convenience delay action to Main thread
    public static func asyncToMain(after timeInterval: TimeInterval, block: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + timeInterval) {
            block()
        }
    }
}
