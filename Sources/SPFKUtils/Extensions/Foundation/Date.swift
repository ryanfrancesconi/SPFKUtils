// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/SPFKUtils

import Foundation

// MARK: - Common Date string formatting

fileprivate let dateStyleLong: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .long
    dateFormatter.timeStyle = .long
    dateFormatter.locale = .current
    return dateFormatter
}()

fileprivate let dateStyleSimple: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MMM d, h:mm a"
    dateFormatter.locale = .current
    return dateFormatter
}()

fileprivate let dateStyleMedium: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .medium
    dateFormatter.timeStyle = .short
    dateFormatter.locale = .current
    return dateFormatter
}()

fileprivate let dateStyleNoTime: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .long
    dateFormatter.timeStyle = .none
    dateFormatter.locale = .current
    return dateFormatter
}()

extension Date {
    public var longString: String { // formattedString
        dateStyleLong.string(from: self)
    }

    public var mediumString: String {
        dateStyleMedium.string(from: self)
    }

    public var simpleString: String {
        dateStyleSimple.string(from: self)
    }

    public var onlyDateString: String {
        dateStyleNoTime.string(from: self)
    }
}

extension StringProtocol {
    public func toDate() -> Date? {
        switch self {
        case let str as String:
            return dateStyleLong.date(from: str)
        default:
            return dateStyleLong.date(from: String(self))
        }
    }
}

extension Date {
    public init?(
        posix string: String,
        dateFormat: String? = nil
    ) {
        let dateFormat = dateFormat ?? "yyyy-MM-dd'T'HH:mm:ss.SSSSSSS'Z'"
        let dateFormatter = DateFormatter()
        let enUSPosixLocale = Locale(identifier: "en_US_POSIX")
        dateFormatter.locale = enUSPosixLocale
        dateFormatter.dateFormat = dateFormat
        guard let formDate = dateFormatter.date(from: string) else { return nil }
        self = formDate
    }
}
