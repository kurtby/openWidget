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
            VStack(spacing: 0) {
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
                    .frame(maxWidth: 160)
                    .frame(minHeight: 0, maxHeight: .infinity, alignment: .top)
            
                    Spacer()
                   
                    if let w = entry.weather {
                        WeatherView(weather: w)
                            .frame(minHeight: 0, maxHeight: .infinity, alignment: .top)
                    }
                }
                .frame(height: 134)
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
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .top)
            .padding(4)
           
            if let events = model.nextEvents, !events.isEmpty {
                Group {
                    LinearGradient(gradient: Gradient(colors: [Color.bottomGradient, Color.bottomGradient.opacity(1), Color.bottomGradient.opacity(0.1)]), startPoint: .bottom, endPoint: .top)
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
    
    struct BottomCounter {
        var count: Int = 0
        var type: String = ""
            
        var title: String {
            return "\(count) \(type)"
        }
        
        var isEmpty: Bool {
            return count == 0
        }
    }
    
    var counter: BottomCounter {
        var counter = BottomCounter()
        let needActionCount = events.filter({$0.eventStatus == .needAction}).count
        let personalCount = events.filter({$0.calendar.calendarType == .personal}).count
        
        if needActionCount > 0 {
            counter.type = "приглашение"
            counter.count = needActionCount
        }
        else if personalCount > 0 {
            counter.type = "события"
            counter.count = personalCount
        }
         
        return counter
    }
    
    var body: some View {
        HStack {
            if !counter.isEmpty {
                Text(counter.title)
                    .font(.system(size: 13, weight: .medium, design: .default))
                    .foregroundColor(Color.buttonTextTitle)
                    .accessibility(identifier: "CalendarBootomViewCountLabel")
            }
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


