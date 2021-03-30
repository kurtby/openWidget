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
        EventModelData(events: entry.data.events ?? [], calendars: entry.configuration.calendarType ?? [])
    }
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        if entry.data.isNoConnection {
            NoInternetConnection()
        }
        else {
            ZStack(alignment: .bottom) {
                VStack(spacing: 0) {
                    HStack {
                        Link(destination: URL(string: Constants.DeepLink.Event.calendar.url)!) {
                            CalendarView { date in
                                Text(date.shortDateString)
                                    .font(.system(size: 10))
                                    .foregroundColor(getDayColor(date: date))
                                    .frame(width: 20, height: 20)
                                    .background(Calendar.current.isDateInToday(date) ? Color.Calendar.viewCurrentDayBackground : Color.clear)
                                    .cornerRadius(8)
                                    .shadow(color: colorScheme == .light ? Color.Calendar.viewCurrentDayShadow : .clear, radius: 28, x: 0, y: 5)
                                    .shadow(color: colorScheme == .light ? Color.Calendar.viewCurrentDayShadow : .clear, radius: 10, x: 0, y: 4)
                            }
                            .frame(maxWidth: 160)
                            .frame(minHeight: 0, maxHeight: .infinity, alignment: .top)
                        }
                
                        Spacer()
                       
                        if let w = entry.data.weather {
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
                        BootomView(events: events, isHaveInvites: entry.data.isHaveInvites)
                    }
                }
            }
        }
    }
    
    private func getDayColor(date: Date) -> Color {
        if Calendar.current.isDateInToday(date) {
            return Color.Calendar.currentDayTitle
        }
   
        return (Calendar.current.isDateInWeekend(date) || !Calendar.current.isDate(date, equalTo: Date(), toGranularity: .month) ? Color.Calendar.viewWeekDay : Color.Calendar.viewDay)
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
            
            if let url = URL(string: Constants.DeepLink.Event.create.url) {
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
    let isHaveInvites: Bool
    
    struct BottomCounter {
        var count: Int = 0
        var type: String = ""
            
        var title: String {
            return "\(type)"
        }
        
        var isEmpty: Bool {
            return count == 0
        }
    }
    
    var counter: BottomCounter {
        var counter = BottomCounter()
        let needActionCount = events.filter({$0.eventStatus == .needAction}).count
        let personalCount = events.filter({Calendar.current.isDateInToday($0.from) && $0.fullDay == false}).count
        
        if isHaveInvites {
            counter.type = "Приглашения"
            counter.count = needActionCount == 0 ? 1 : needActionCount
        }
        else if personalCount > 0 {
            counter.type = String.localizedStringWithFormat(     Constants.LocalizablePluralKey.event.rawValue.localized, personalCount)
            counter.count = personalCount
        }
         
        return counter
    }
  
    
    var body: some View {
        HStack {
            if !counter.isEmpty {
                if isHaveInvites {
                    if let url = URL(string: Constants.DeepLink.Event.inbox.url) {
                        Link(destination: url) {
                            Text(counter.title)
                                .font(.system(size: 13, weight: .medium, design: .default))
                                .foregroundColor(Color.buttonTextTitle)
                                .accessibility(identifier: "CalendarBootomViewCountLabel")
                        }
                    }
                    else {
                        Text(counter.title)
                            .font(.system(size: 13, weight: .medium, design: .default))
                            .foregroundColor(Color.buttonTextTitle)
                            .accessibility(identifier: "CalendarBootomViewCountLabel")
                    }
                }
                else {
                    Text(counter.title)
                        .font(.system(size: 13, weight: .medium, design: .default))
                        .foregroundColor(Color.buttonTextTitle)
                        .accessibility(identifier: "CalendarBootomViewCountLabel")
                }
            }
            Spacer()
            if let url = URL(string: Constants.DeepLink.Event.create.url) {
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

struct NoInternetConnection: View {
    var body: some View {
        ZStack(alignment: .top) {
            HStack {
                Spacer()
                Image("app_mail_icon")
                    .frame(width: 16, height: 16)
            }
            .padding(.top, 15)
            .padding(.trailing, 15)
            
            VStack(alignment: .center, spacing: 24) {
                Text("Ошибка загрузки данных из сети")
                    .font(.system(size: 15, weight: .regular, design: .default))
                    .foregroundColor(.emptyTextInfo)
                    .frame(width: 200)
                    .multilineTextAlignment(.center)
                    .accessibility(identifier: "NoEventsFoundStackViewTitleLabel")
                
                if let url = URL(string: Constants.DeepLink.Event.reload.url) {
                    Link(destination: url) {
                        HStack(spacing: 10) {
                            Image("button_icon_reload")
                            Text("Повторить загрузку").font(.system(size: 15, weight: .regular, design: .default)).foregroundColor(.buttonTextTitle)
                        }
                        
                    }
                    .frame(width: 199, height: 44)
                    .background(Color.buttonBackground)
                    .cornerRadius(12)
                    .accessibility(identifier: "NoEventsFoundStackViewCreateButton")
                }
            }
            .accessibility(identifier: "NoEventsFoundStackView")
            .frame(minWidth: 0, maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, minHeight: /*@START_MENU_TOKEN@*/0/*@END_MENU_TOKEN@*/, maxHeight: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
        }
     
    }
    
}
