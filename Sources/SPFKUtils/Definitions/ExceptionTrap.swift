// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/SPFKUtils

import SPFKUtilsC

public struct ExceptionTrap {
    public static func withThrowing(_ block: @escaping (() throws -> Void)) throws {
        var swiftError: Error?

        // objc
        ExceptionCatcherOperation({
            do {
                try block()
            } catch {
                swiftError = error
            }
        }, { exception in
            swiftError = exception.error
        })

        if let swiftError {
            throw swiftError
        }
    }
}
