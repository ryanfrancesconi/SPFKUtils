// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/SPFKUtils

import AppKit
import Foundation

public struct BundleProperties {
    public var applicationVersion = ApplicationVersion()

    public init() {}

    public var appVersion: String? {
        guard let string = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String else {
            return nil
        }
        return string + " \(Log.buildConfig)"
    }

    public var appName: String? = Bundle.main.infoDictionary?["CFBundleName"] as? String
    public var appVersionBuild: String? = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
    public var appCopyright: String? = Bundle.main.infoDictionary?["NSHumanReadableCopyright"] as? String
    public var appCopyrightShort: String? = Bundle.main.infoDictionary?["ShortCopyright"] as? String

    public var fullApplicationVersion: String? {
        guard let versionBuildNumber,
              let appName else { return nil }
        return "\(appName) \(versionBuildNumber)"
    }

    public var versionBuildNumber: String? {
        guard let appVersion,
              let appVersionBuild else { return nil }
        return "\(appVersion) (Build \(appVersionBuild))"
    }

    public var appModificationDate: Date? {
        let infoPath = Bundle.main.bundleURL.path
        guard let infoAttr = try? FileManager.default.attributesOfItem(atPath: infoPath),
              let infoDate = infoAttr[.modificationDate] as? Date else { return nil }

        return infoDate
    }

    public var appVersionAndCopyright: String {
        var info = ""

        if let fullApplicationVersion {
            info += fullApplicationVersion + "\n"
        }

        if let appModificationDate {
            let builtOnDate = "Built on \(appModificationDate.formattedString3)"
            info += "\(builtOnDate)\n"
        }

        if let appCopyright {
            info += "\(appCopyright)\n"
        }

        return info
    }

    // String for the About / Splash Window
    public var systemDescription: String {
        appVersionAndCopyright +
            "\n" +
            HardwareInfo.description
    }

    public static func relaunch(afterDelay seconds: TimeInterval = 0.5) -> Never {
        let task = Process()
        task.launchPath = "/bin/sh"
        task.arguments = ["-c", "sleep \(seconds); open \"\(Bundle.main.bundlePath)\""]
        task.launch()

        NSApp.terminate(self)
        exit(0)
    }
}

extension BundleProperties {
    /// Return this applications Caches directory based on the main bundle ID such as
    /// /Users/YOU/Library/Caches/com.audiodesigndesk.ADD
    public static var cachesDirectory: URL? {
        guard let caches = FileManager.default.urls(
            for: .cachesDirectory,
            in: .userDomainMask)
            .first,
            let id = Bundle.main.bundleIdentifier else {
            return nil
        }
        return caches.appendingPathComponent(id)
    }

    public static var documentsDirectory: URL? {
        FileManager.default.urls(for: .documentDirectory,
                                 in: .userDomainMask).first
    }

    public static var applicationSupportDirectory: URL? {
        FileManager.default.urls(for: .applicationSupportDirectory,
                                 in: .userDomainMask).first
    }

    public static let appFolder: URL = Bundle.main.bundleURL.deletingLastPathComponent()
}

extension BundleProperties {
    /**
     Given a version number MAJOR.MINOR.PATCH, increment the:
     MAJOR version when you make incompatible API changes
     MINOR version when you add functionality in a backward compatible manner
     PATCH version when you make backward compatible bug fixes
     */
    public struct ApplicationVersion {
        public private(set) var major: Int = 0
        public private(set) var minor: Int = 0
        public private(set) var patch: Int = 0
        public private(set) var build: Int = 0

        public init() {
            guard let shortVersion = Bundle.main.infoDictionaryString(key: "CFBundleShortVersionString") else { return }

            let parts = shortVersion
                .components(separatedBy: ".")
                .map { Int($0) ?? 0 }

            if parts.count >= 3 {
                major = parts[0]
                minor = parts[1]
                patch = parts[2]
            }

            if let value = Bundle.main.infoDictionaryString(key: "CFBundleVersion") {
                build = Int(value) ?? 0
            }
        }
    }
}
