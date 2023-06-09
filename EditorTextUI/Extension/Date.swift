//
//  Date.swift
//  SwiftUITemplate
//
//  Created by apple on 29/03/2023.
//

import Foundation

enum DateFormat: String {
    case date = "dd MMM HH:mm"
}

// MARK: - Date

extension Date {
    func minute(adding value: Int) -> Date {
        return Calendar.current.date(byAdding: .minute, value: value, to: self) ?? Date()
    }

    func toString(format: DateFormat, localize: Bool) -> String {
        let fmt = DateFormatter.fromFormat(format: format.rawValue)
        fmt.locale = Locale(identifier: "en_US")
        fmt.timeZone = localize ? TimeZone.current : TimeZone.utcTimeZone()
        return fmt.string(from: self)
    }
}

// MARK: - DateFormatter

extension DateFormatter {
    static func fromFormat(format: String) -> DateFormatter {
        let fmt = DateFormatter()
        fmt.dateFormat = format
        return fmt
    }
}

// MARK: - TimeZone

extension Foundation.TimeZone {
    static func utcTimeZone() -> Foundation.TimeZone {
        return Foundation.TimeZone(secondsFromGMT: 0) ?? Foundation.TimeZone.current
    }
}
