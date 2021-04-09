//
//  Network+ResponseData.swift
//  MRCalendarWidget
//
//  Created by Valentine Eyiubolu on 5.04.21.
//

import Foundation

extension Network {
    
    struct ResponseData {
        var events: [Event]?
        var weather: Weather?
        var calendars: [EventsCalendar]?
        
        var errors: [Error] = []
        var isHaveInvites: Bool = false
        
        var isNoConnection: Bool {
            if let err = errors.first as? URLError, err.code == URLError.Code.notConnectedToInternet {
                return true
            }
            
            return false
        }
        
        var isNeedAuth: Bool {
            if let err = errors.first as? URLError, err.code == URLError.Code.userAuthenticationRequired {
                return true
            }
            
            return false
        }
    }
    
}
