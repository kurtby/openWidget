//
//  APITokenStorage.swift
//  MRCalendarWidget
//
//  Created by Valentine Eyiubolu on 2.04.21.
//

import Foundation

class APITokenStorage {
    
    public func save(_ token: APIToken?) {
        
        guard let refreshToken = token?.refreshToken, let accessToken = token?.accessToken else {
            return
        }
    
        Defaults.save(accessToken, .accessToken)
        Defaults.save(refreshToken, .token)
     
        if let expireDate = token?.expiresAt {
            Defaults.save(expireDate, .accessTokenExpireDate)
        }
    }

    public func get() -> APIToken? {
        
        guard let refreshToken = Defaults.get(.token) as? String, let accessToken = Defaults.get(.accessToken) as? String else {
            return nil
        }
        
        let expireDate = Defaults.get(.accessTokenExpireDate) as? Date

        return APIToken(accessToken: accessToken, expiresAt: expireDate, refreshToken: refreshToken)
    }
    
}
