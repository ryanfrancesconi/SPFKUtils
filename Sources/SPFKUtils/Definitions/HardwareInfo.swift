import Darwin
import Foundation

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
        // sysctl(name: "hw.perflevel0.physicalcpu")

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

    private static let HOST_BASIC_INFO_COUNT: mach_msg_type_number_t =
        UInt32(MemoryLayout<host_basic_info_data_t>.size / MemoryLayout<integer_t>.size)

    fileprivate static func hostBasicInfo() -> host_basic_info {
        var size = HOST_BASIC_INFO_COUNT
        let hostInfo = host_basic_info_t.allocate(capacity: 1)

        let result = hostInfo.withMemoryRebound(to: integer_t.self, capacity: Int(size)) {
            host_info(mach_host_self(), HOST_BASIC_INFO, $0, &size)
        }

        let data = hostInfo.move()
        hostInfo.deallocate()

        if Log.buildConfig == .debug {
            if result != KERN_SUCCESS {
                Log.error("ERROR - \(#file):\(#function) - kern_result_t = " + "\(result)")
            }
        }

        return data
    }
}
