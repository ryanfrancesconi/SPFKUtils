// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/SPFKUtils

import Darwin
import Foundation

/// Only accounting for macOS
public enum HardwareInfo {
    public enum ChipType: String {
        case x86_64
        case arm64

        public var description: String {
            switch self {
            case .arm64: return "Apple Silicon"
            case .x86_64: return "Intel"
            }
        }
    }

    /// For late-model Intel Macs, this returns x86_64. For Apple Silicon, it returns arm64.
    public static let chip: ChipType? = {
        var sysinfo = utsname()
        let result = uname(&sysinfo)

        guard result == EXIT_SUCCESS else { return nil }

        let data = Data(bytes: &sysinfo.machine, count: Int(_SYS_NAMELEN))

        guard let identifier = String(bytes: data, encoding: .ascii) else { return nil }

        let rawValue = identifier.trimmingCharacters(in: .controlCharacters)

        return ChipType(rawValue: rawValue)
    }()

    private static func sysctl(name: String) -> String {
        var size = 0

        sysctlbyname(name, nil, &size, nil, 0)

        var machine = [CChar](repeating: 0, count: size)

        sysctlbyname(name, &machine, &size, nil, 0)

        return String(cString: machine)
    }

    // MARK: - conveniences

    /// Apple M1 Max, etc
    public static let chipname: String = {
        sysctl(name: "machdep.cpu.brand_string")
    }()

    public static let memory: String = {
        let memory = ProcessInfo.processInfo.physicalMemory / ByteCount.gigabyte.rawValue
        return "\(memory) GB memory"
    }()

    public static let cores: Int = {
        ProcessInfo.processInfo.activeProcessorCount
    }()

    public static let description: String = {
        let os = ProcessInfo.processInfo.operatingSystemVersionString
        let cores = ProcessInfo.processInfo.activeProcessorCount

        var info = ""

        info += "macOS \(os)\n"
        info += "\(chipname), "
        info += "\(cores) cores. "
        info += "\(memory).\n\n"

        return info
    }()
}
