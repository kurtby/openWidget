//
//  DateFormatterExtension.swift
//  CalendarWidgetExtension
//
//  Created by Valentine Eyiubolu on 10.02.21.
//

import Foundation

extension DateFormatter {

    static func format(_ date: Date, format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.autoupdatingCurrent
        dateFormatter.setLocalizedDateFormatFromTemplate(format)
        return dateFormatter.string(from: date)
    }
    
    static var month: DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale.autoupdatingCurrent
        formatter.setLocalizedDateFormatFromTemplate("MMMM")
        return formatter
    }
    
    static func relativeDateFormatter(_ date: Date) -> String {
        let relativeDateFormatter = DateFormatter()
        relativeDateFormatter.timeStyle = .none
        relativeDateFormatter.dateStyle = .medium
        relativeDateFormatter.doesRelativeDateFormatting = true
        relativeDateFormatter.locale = Locale.autoupdatingCurrent
        return relativeDateFormatter.string(from: date)
    }

}
