//
//  Defaults.swift
//  MRCalendarWidget
//
//  Created by Valentine Eyiubolu on 31.03.21.
//

import Foundation

struct Defaults {
    
    enum Key: String {
        case refreshToken = "token_key"
        case widgetRefreshToken
        case accessToken
        case accessTokenExpireDate
    }
    
    private static let userDefault = UserDefaults(suiteName: Constants.App.appGroupBundle)
    
    static func save(_ value: Any, _ key: Key) {
        self.userDefault?.setValue(value, forKey: key.rawValue)
    }
    
    static func get(_ key: Key) -> Any? {
        self.userDefault?.value(forKey: key.rawValue)
    }
    
}

