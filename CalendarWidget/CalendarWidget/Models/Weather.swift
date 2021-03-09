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
        
        let hour = Calendar.current.component(.hour, from: Date())
        
        let isDay = hour >= 6 && hour <= 18
        
        switch iconNumber {
        // Sunnny
        case 1,2,59,60:
            return isDay ? "74" : "76"
        // Cloudy
        case 3,4,51,55,58:
            return isDay ? "50" : "52"
        // Rain
        case 11,12,19,20,52:
            return isDay ? "54" : "56"
        // Thunderstorm
        case 46:
            return isDay ? "86" : "88"
        // Sunny Cloudy
        case 5,6,7,8,56,57:
            return isDay ? "46" : "48"
        // Sunny Cloudy Rain
        case 47,48,49,50:
            return isDay ? "66" : "68"
        // Rain Snow
        case 10,15,16,25,26,29,30,31,32,37,38,42,54:
            return isDay ? "58" : "60"
        // Sunny Snow
        case 23,24,43,44:
            return isDay ? "70" : "72"
        // Cloudy Rain Snow
        case 17,18,27,28,33,34:
            return isDay ? "78" : "80"
        case 13,14:
        // Sunny Cloudy Rain
            return isDay ? "66" : "68"
        case 21,22,35,36,41,45,53:
        // Snow
            return isDay ? "62" : "64"
        default:
            return ""
        }
    }
}
