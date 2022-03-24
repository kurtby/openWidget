//
//  UserDefaultsExtension.swift
//  MRCalendarWidget
//
//  Created by Valentine Eyiubolu on 19.02.21.
//

import Foundation

extension UserDefaults {
    static let appGroup = UserDefaults(suiteName: "group.ru.mail.calendar.widget")!
    
    enum Keys: String {
        case refreshToken = "token_key"
        case widgetRefreshToken
        case accessToken
        case accessTokenExpireDate
    }
}
