//
//  Weather.swift
//  CalendarWidgetExtension
//
//  Created by Valentine Eyiubolu on 20.02.21.
//

import Foundation

struct Weather: Codable {
    var city: String
    var region: String
    var temperature: String
    var description: String
    var humidity: String
    var pressure: String
    var wind: String
    var url: String
    var imageUrl: String
}

extension Weather {
    enum CodingKeys: String, CodingKey {
        case city
        case region
        case temperature = "now_temp"
        case description = "now_description"
        case humidity = "now_humidity"
        case pressure = "now_pressure"
        case wind = "now_wind"
        case url = "region_link"
        case imageUrl = "icon"
    }
}

extension Weather {
    
    var assetsImageName: String {
        iconImageName(from: self.imageUrl)
    }
    
    private func iconImageName(from iconURL: String) -> String {
       
        let number = (iconURL as NSString).lastPathComponent

        guard let iconNumberString = number.components(separatedBy: ".").first,
            let iconNumber = Int(iconNumberString) else { return "" }
        
        switch iconNumber {
        case 1,2,59,60:
            return "weather_icon_sunny"
        case 3,4,51,55,58:
            return "weather_icon_cloudy"
        case 11,12,19,20,52:
            return "weather_icon_rain"
        case 46:
            return "weather_icon_sunny_thunderstorm"
        case 5,6,7,8,56,57:
            return "weather_icon_cloudy"
        case 47,48,49,50:
            return "weather_icon_sunny_cloudy_rain"
        case 10,15,16,25,26,29,30,31,32,37,38,42,54:
            return "weather_icon_rain_snow"
        case 23,24,43,44:
            return "weather_icon_sunny_snow"
        case 17,18,27,28,33,34:
            return "weather_icon_sunny_cloudy_rain_snow"
        case 13,14:
            return "weather_icon_sunny_cloudy_rain_snow"
        case 21,22,35,36,41,45,53:
            return "weather_icon_snow"
        default:
            return ""
        }
    }
}
