//
//  ColorExtension.swift
//  MRCalendarWidget
//
//  Created by Valentine Eyiubolu on 10.02.21.
//

import SwiftUI

extension Color {
    
    struct Calendar {
        static let gradientStart = Color("CalendarViewGradientStart")
        static let gradientEnd = Color("CalendarViewGradientEnd")
        
        static let headerTitle = Color("CalendarViewHeaderTitle")
        
        static let weekDayTitle = Color("CalendarViewDaysTitle")
        
        static let viewDay = Color("CalendarViewDay")
        
        static let viewWeekDay = Color("CalendarViewWeekDay")
        
        static let viewCurrentDay = Color("CalendarViewCurrentDay")
        
        static let viewCurrentDayShadow = Color("CalendarViewCurrentDayShadow")
        
        static let viewDarkBackground = Color("CalendarViewDarkBackground")
    }
    
    struct Event {
        struct Time {
            static let title = Color("EventTimeTitle")
            static let titlePending = Color("EventTimeTitlePending")
            
            static let borderDash = Color("EventTimeBorderDash")
            static let borderDashPending = Color("EventTimeBorderDashPending")
            
            static let background = Color("EventTimeBackground")            
        }
        
        static let eventUserBorder = Color("EventUserBorder")
        
        static let buttonBackground = Color("EventButtonBackground")
    }
    
    static let buttonBackground = Color("ButtonBackground")
    
    static let buttonTextTitle = Color("ButtonTextTitle")
    static let emptyTextInfo = Color("EmptyTextInfo")
    
    static let widgetBackground = Color("WidgetBackground")
    
    static let bottomGradient = Color("BottomGradient")
    
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
