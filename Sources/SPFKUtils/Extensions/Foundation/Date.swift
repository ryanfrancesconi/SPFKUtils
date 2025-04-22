// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/SPFKUtils

import Foundation

// MARK: - Common Date string formatting

fileprivate let generalDateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .long
    dateFormatter.timeStyle = .long
    dateFormatter.locale = .current
    return dateFormatter
}()

fileprivate let simpleDateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MMM d, h:mm a"
    dateFormatter.locale = .current
    return dateFormatter
}()

fileprivate let generalDateFormatter2: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .long
    dateFormatter.timeStyle = .short
    dateFormatter.locale = .current
    return dateFormatter
}()

fileprivate let generalDateFormatter3: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .long
    dateFormatter.timeStyle = .none
    dateFormatter.locale = .current
    return dateFormatter
}()

extension Date {
    public var formattedString: String {
        generalDateFormatter.string(from: self)
    }

    public var formattedString2: String {
        generalDateFormatter2.string(from: self)
    }

    public var formattedString3: String {
        generalDateFormatter3.string(from: self)
    }

    public var simpleString: String {
        simpleDateFormatter.string(from: self)
    }
}

extension StringProtocol {
    public func toDate() -> Date? {
        switch self {
        case let str as String:
            return generalDateFormatter.date(from: str)
        default:
            return generalDateFormatter.date(from: String(self))
        }
    }
}

extension Date {
    public init?(posix string: String,
                 dateFormat: String? = nil) {
        let dateFormat = dateFormat ?? "yyyy-MM-dd'T'HH:mm:ss.SSSSSSS'Z'"
        let dateFormatter = DateFormatter()
        let enUSPosixLocale = Locale(identifier: "en_US_POSIX")
        dateFormatter.locale = enUSPosixLocale
        dateFormatter.dateFormat = dateFormat
        guard let formDate = dateFormatter.date(from: string) else { return nil }
        self = formDate
    }
}
