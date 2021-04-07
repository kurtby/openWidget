//
//  Log.swift
//  MRCalendarWidget
//
//  Created by Valentine Eyiubolu on 6.04.21.
//

import Foundation
import os

enum Log {
    static let subsystem = Bundle.main.bundleIdentifier ?? "ru.mail.widget"
    
    static func createLogger(category: Categories) -> Logger {
        Logger(subsystem: subsystem, category: category.category)
    }

}

extension Log {
    struct Categories: ExpressibleByStringLiteral {
        var category: String = ""

        init(category: String) {
            self.category = category
        }
        
        init(stringLiteral value: String) {
            self = .init(category: value)
        }
    }
}
