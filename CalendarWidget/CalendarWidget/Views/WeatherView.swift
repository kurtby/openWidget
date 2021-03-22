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
        Link(destination: URL(string: Constants.DeepLink.Event.url(weather.url).url)!) {
            VStack(alignment: .center, spacing: 0) {

                HStack {
                    Spacer()
                    Image("app_mail_icon")
                        .frame(width: 16, height: 16)
                }
                .padding(.top, 10)
                .padding(.trailing, 10)
                
                Image(weather.assetsImageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 56, height: 56, alignment: .top)
                    .accessibility(identifier: "WeatherViewImage")
            
                Group {
                    Text(weather.temperature + "° " + weather.description.capitalizingFirstLetter())
                        .lineLimit(2)
                        .font(.system(size: 12, weight: .regular, design: .default))
                        .foregroundColor(Color.buttonTextTitle)
                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(.center)
                        .frame(width: 120, height: 28)
                        .accessibility(identifier: "WeatherViewDescriptionLabel")
                }
                .padding(.top, 3)
                .padding(.bottom, 1)
              
            }
            .accessibility(identifier: "WeatherView")
        }
        
    }
    
}
