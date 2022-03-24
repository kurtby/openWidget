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
        
        static let viewCurrentDayBackground = Color("CalendarViewCurrentDayBackground")
        
        static let viewCurrentDayShadow = Color("CalendarViewCurrentDayShadow")
        
        static let viewDarkBackground = Color("CalendarViewDarkBackground")
        
        static let currentDayTitle = Color("CalendarViewCurrentDay")
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

extension Color.Event.Time {
    
    static func applyColor(originalColor: Color, colorScheme: ColorScheme, reverse: Bool = false) -> Color {
        
        if colorScheme == (reverse ? .light : .dark) { return originalColor }
        
        let hue = originalColor.hsl.hue
        
        return Color(hsl: Color.HSL(hue: hue, saturation: 50, lightness: 24))
    }
    
}

// Color hex init
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

// HSL Color
extension Color {
    
    struct HSL: Hashable {
        var hue: CGFloat
        var saturation: CGFloat
        var lightness: CGFloat
    }
    
    init(hsl: HSL, alpha: CGFloat = 1.0) {
        let h = hsl.hue / 360.0
        var s = hsl.saturation / 100.0
        let l = hsl.lightness / 100.0

        let t = s * ((l < 0.5) ? l : (1.0 - l))
        let b = l + t
        s = (l > 0.0) ? (2.0 * t / b) : 0.0

        self.init(hue: Double(h), saturation: Double(s), brightness: Double(b), opacity: Double(alpha))
    }
    
    var hsl: HSL {
        var (h, s, b) = (CGFloat(), CGFloat(), CGFloat())
        
        self.uiColor().getHue(&h, saturation: &s, brightness: &b, alpha: nil)
        
        let l = ((2.0 - s) * b) / 2.0

        switch l {
        case 0.0, 1.0:
            s = 0.0
        case 0.0..<0.5:
            s = (s * b) / (l * 2.0)
        default:
            s = (s * b) / (2.0 - l * 2.0)
        }

        return HSL(hue: h * 360.0,
                   saturation: s * 100.0,
                   lightness: l * 100.0)
    }
    
}

// SwiftUI to UIColor
extension Color {
    
    func uiColor() -> UIColor {
        UIColor(self)
    }
    
}
