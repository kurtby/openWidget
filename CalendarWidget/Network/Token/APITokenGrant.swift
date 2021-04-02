//
//  APITokenGrant.swift
//  MRCalendarWidget
//
//  Created by Valentine Eyiubolu on 31.03.21.
//

import Foundation

public enum APITokenGrant {
    
    case refreshToken(String)

    public var parameters: [String: String] {
        switch self {
        case let .refreshToken(refreshToken):
            return [
                "client_id": Constants.App.clientID,
                "grant_type": "refresh_token",
                "refresh_token": refreshToken,
            ]
        }
    }
}
