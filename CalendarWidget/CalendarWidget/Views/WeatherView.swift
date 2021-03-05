//
//  WeatherView.swift
//  CalendarWidgetExtension
//
//  Created by Valentine Eyiubolu on 8.02.21.
//

import SwiftUI

struct WeatherView: View {
    let weather: Weather
   
    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .center, spacing: 8) {
                Link(destination: URL(string: Constants.DeepLink.Event.url(weather.url).urlSceme)!, label: {
                    Image(weather.assetsImageName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 56, height: 56)
                })
                
                Text(weather.temperature + "° " + weather.description.capitalizingFirstLetter())
                    .lineLimit(2)
                    .font(.system(size: 13, weight: .regular, design: .default))
                    .foregroundColor(Color.buttonTextTitle)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: 120)
            }
            
            VStack {
                Image("app_mail_icon")
                Spacer()
            }
            .frame(maxHeight: .infinity)
            .padding(.trailing, 12)
            .padding(.top, 12)
        }
        .padding(.trailing, 0)
        
    }
}
