// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/SPFKUtils

import Foundation
import os.log

/// A simple wrapper on os_log for supporting debug, info or errors out.
public struct Log {
    /// Global build config variable.
    /// Set once immediately on app launch. Then app and all packages can read it.
    nonisolated(unsafe) public static var buildConfig: BuildConfig = .debug

    static let defaultSubsystem: String = {
        Bundle.main.bundleIdentifier ?? "com.spongefork"
    }()

    @inline(__always)
    static let defaultLog = OSLog(subsystem: defaultSubsystem, category: "Info")

    @inline(__always)
    static let debugLog = OSLog(subsystem: defaultSubsystem, category: "Debug")

    @inline(__always)
    static let errorLog = OSLog(subsystem: defaultSubsystem, category: "Errors")

    @inline(__always)
    private static func logError(_ message: String) {
        os_log("%{public}@", log: errorLog, type: .error, message)
    }

    @inline(__always)
    private static func logInfo(_ message: String) {
        os_log("%{public}@", log: defaultLog, type: .info, message)
    }

    @inline(__always)
    private static func logDebug(_ message: String) {
        os_log("%{public}@", log: debugLog, type: .debug, message)
    }

    @inline(__always)
    private static func assembleMessage(
        file: String = #file,
        function: String = #function,
        line: Int = #line,
        _ items: Any?...
    ) -> String {
        let fileName = (file as NSString).lastPathComponent

        let content = items.map {
            String(describing: $0 ?? "nil")
        }.joined(separator: " ")

        let message = "\(fileName):\(function):\(line):\(content)"

        return message
    }

    // MARK: - Public

    @inline(__always)
    public static func `default`(
        file: String = #file,
        function: String = #function,
        line: Int = #line,
        _ items: Any?...
    ) {
        autoreleasepool {
            let message = assembleMessage(file: file, function: function, line: line, items)
            logInfo(message)
        }
    }

    @inline(__always)
    public static func debug(
        file: String = #file,
        function: String = #function,
        line: Int = #line,
        _ items: Any?...
    ) {
        guard buildConfig != .release else { return }

        autoreleasepool {
            let message = assembleMessage(file: file, function: function, line: line, items)
            logDebug(message)
        }
    }

    @inline(__always)
    public static func error(
        file: String = #file,
        function: String = #function,
        line: Int = #line,
        _ items: Any?...
    ) {
        autoreleasepool {
            let message = "🚩 " + assembleMessage(file: file, function: function, line: line, items)
            logError(message)
        }
    }

    public static func printCallStack() {
        var lines: [String] = ["\n"]

        Thread.callStackSymbols.forEach {
            lines.append($0)
        }

        Log.error(
            lines.joined(separator: "\n")
        )
    }
}
