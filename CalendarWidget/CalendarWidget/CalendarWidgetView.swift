//
//  CalendarWidgetView.swift
//  CalendarWidgetExtension
//
//  Created by Valentine Eyiubolu on 19.02.21.
//

import Foundation
import SwiftUI

struct CalendarWidgetEntryView: View {
    
    var entry: CalendarWidgetTimelineProvider.Entry
    
    var model: EventModelData {
        EventModelData(events: entry.events ?? [], calendars: entry.configuration.calendarType ?? [])
    }
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack {
                HStack {
                    CalendarView { date in
                        Text(date.shortDateString)
                            .font(.system(size: 10))
                            .foregroundColor(Calendar.current.isDateInWeekend(date) || !Calendar.current.isDate(date, equalTo: Date(), toGranularity: .month) ?  Color.Calendar.viewWeekDay : Color.Calendar.viewDay)
                            .frame(width: 20, height: 20)
                            .background(Calendar.current.isDateInToday(date) ? Color.Calendar.viewCurrentDay : Color.clear)
                            .cornerRadius(8)
                            .shadow(color: colorScheme == .light ? Color.Calendar.viewCurrentDayShadow : .clear, radius: 28, x: 0, y: 5)
                            .shadow(color: colorScheme == .light ? Color.Calendar.viewCurrentDayShadow : .clear, radius: 10, x: 0, y: 4)
                    }
                    .frame(maxWidth: 152)
            
                    Spacer()
                   
                    if let w = entry.weather {
                        WeatherView(weather: w)
                    }
                }
                .frame(height: 128)
                .if(colorScheme == .light) {
                    $0.background(RadialGradient(gradient: Gradient(colors: [Color.Calendar.gradientStart, Color.Calendar.gradientEnd]), center: .topTrailing, startRadius: 30, endRadius: 250))
                } else: {
                    $0.background(Color.Calendar.viewDarkBackground)
                }
                .cornerRadius(19)
                
                if let events = model.nextEvents , !events.isEmpty {
                    EventsView(modelData: model)
                }
                else {
                    Spacer()
                    NoEventsFoundView()
                    Spacer()
                }
            }
            .padding(4)
        
            if let events = model.nextEvents, !events.isEmpty {
                ZStack(alignment: .bottom) {
                    LinearGradient(gradient: Gradient(colors: [Color.bottomGradient, Color.bottomGradient.opacity(0.75), Color.bottomGradient.opacity(0.1)]), startPoint: .bottom, endPoint: .top)
                    .frame(height: 60)
                    BootomView(events: events)
                }
            }
        }
    }
}

struct NoEventsFoundView: View {
    var body: some View {
        VStack(alignment: .center, spacing: 24) {
            Text("На сегодня событий больше нет")
                .font(.system(size: 15, weight: .regular, design: .default))
                .foregroundColor(.emptyTextInfo)
                .frame(width: 157)
                .multilineTextAlignment(.center)
                .accessibility(identifier: "NoEventsFoundStackViewTitleLabel")
            
            if let url = URL(string: Constants.DeepLink.Event.create.urlSceme) {
                Link(destination: url) {
                    HStack(spacing: 4) {
                        Text("Создать").font(.system(size: 15, weight: .regular, design: .default)).foregroundColor(.buttonTextTitle)
                        Image("button_icon_plus")
                    }
                    
                }
                .frame(width: 112, height: 44)
                .background(Color.buttonBackground)
                .cornerRadius(12)
                .accessibility(identifier: "NoEventsFoundStackViewCreateButton")
            }
        }.accessibility(identifier: "NoEventsFoundStackView")
    }
    
}

struct BootomView: View {
    let events: [Event]
    
    var eventCount: String {
        let needActionCount = events.filter({$0.eventStatus == .needAction}).count
        return needActionCount > 0 ? "\(needActionCount) приглашение" : "\(events.count) события"
    }
    
    var body: some View {
        HStack {
            Text(eventCount)
                .font(.system(size: 13, weight: .medium, design: .default))
                .foregroundColor(Color.buttonTextTitle)
                .accessibility(identifier: "CalendarBootomViewCountLabel")
            Spacer()
            if let url = URL(string: Constants.DeepLink.Event.create.urlSceme) {
                Link(destination: url) {
                    HStack(spacing: 4) {
                        Text("Создать")
                            .font(.system(size: 13, weight: .medium, design: .default))
                            .foregroundColor(Color.buttonTextTitle)
                        Image("button_icon_plus")
                    }
                }.accessibility(identifier: "CalendarBootomViewCreateButton")
            }
        }
        .padding(.leading, 15)
        .padding(.trailing, 16)
        .padding(.bottom, 16)
        .accessibility(identifier: "CalendarBootomStackView")
    }
}


