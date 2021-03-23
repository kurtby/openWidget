//
//  EventsView.swift
//  MRCalendarWidget
//
//  Created by Valentine Eyiubolu on 17.02.21.
//

import SwiftUI
import Combine
import Foundation

struct EventsView: View {
    
    var modelData: EventModelData
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            ForEach(self.modelData.nextEvents, id: \.uid) { event in
                self.view(for: event)
            }
            Spacer(minLength: 0)
        }
        .padding(.top, 15)
    }
    
    private func view(for event: Event) -> some View {
        Group {
            if self.modelData.isDateHeaderNeeded(for: event.from) {
                EventDateHeaderView(date: event.from)
            }
            if event.fullDay == false {
                if let url = URL(string: Constants.DeepLink.Event.openEvent(eventID: event.uid, calendarID: event.calendar.uid).url) {
                    Link(destination: url) {
                        EventView(event: event)
                    }
                }
                else {
                    EventView(event: event)
                }
            }
            else if event.calendar.calendarType == .holidays || event.fullDay {
                if let url = URL(string: Constants.DeepLink.Event.openEvent(eventID: event.uid, calendarID: event.calendar.uid).url) {
                    Link(destination: url) {
                        EventTextView(title: event.title, color: event.calendar.color, isBirthday: event.calendar.isBirthday)
                    }
                }
                else {
                    EventTextView(title: event.title, color: event.calendar.color, isBirthday: event.calendar.isBirthday)
                }
            }
        }
    }
}

struct EventView: View {
    let event: Event

    var subTitle: String {
        var text = "до \(event.to.timeString)"
        
        if let location = event.location , location.description.count > 0 {
            text.append(" в \(location.description)")
        }
        
        return text
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            TimeView(event: event)
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(event.title.isEmpty ? "Без названия" : event.title)
                        .font(.system(size: 15, weight: .semibold, design: .default))
                        .foregroundColor(Color.buttonTextTitle)
                        .lineLimit(1)
                        .accessibility(identifier: "EventViewTitleLabel")
                    Spacer()
                    if event.attendeesCount > 1 {
                        if event.eventStatus == .needAction {
                            if let user = event.organizer {
                                if event.attendeesCount >= 2 {
                                    UsersView(user: user, count: event.attendeesCount, users: event.attendeesConnection.edges.map({$0.node.user}), color: event.calendar.color, status: event.eventStatus)
                                }
                                else {
                                    UsersView(user: user, count: 0, users: [], color: event.calendar.color, status: event.eventStatus)
                                }
                            }
                        }
                        else {
                            if let user = event.organizer {
                                UsersView(user: user, count: event.attendeesCount, users: event.attendeesConnection.edges.map({$0.node.user}), color: event.calendar.color, status: event.eventStatus)
                            }
                        }
                    }
                }
                
                Text(subTitle)
                    .font(.system(size: 14, weight: .regular, design: .default))
                    .foregroundColor(Color.Event.Time.titlePending)
                    .accessibility(identifier: "EventViewSubTitleLabel")
                
                if event.eventStatus == Event.Status.needAction {
                    ButtonsPendingView(event: event)
                }
                // Show call button
                else if let callURL = event.call {
                    // Show button in 10 minutes before start
                    let fromDate: Date = Calendar.current.date(byAdding: .minute, value: Constants.Timing.callOffsetInterval, to: event.from) ?? Date()
                    
                    if Date().isBetween(fromDate, date2: event.to) {
                        ButtonСallView(url: callURL)
                    }
                }
            }
        }
        .padding(.horizontal, 11)
        .accessibility(identifier: "EventView")
    }
}

struct UsersView: View {
    
    @Environment(\.colorScheme) var colorScheme
        
    let user: User?
    var count: Int
    var users: [User]
    var color: String
    var status: Event.Status
    
    var titleColor: Color {
        Color.Event.Time.applyColor(originalColor: Color(hex: color), colorScheme: colorScheme)
    }
    
    var backgroundColor: Color {
        Color.Event.Time.applyColor(originalColor: Color(hex: color), colorScheme: colorScheme, reverse: true)
    }
    
    var stringCount: String {
        if count > 999 {
            return "\(999)+"
        }
        return "\(count)"
    }
    
    var body: some View {
        HStack(alignment: .center, spacing: -7.0) {
            if users.count == 2 {
                ForEach(self.users, id: \.email) { user in
                    self.view(for: user)
                }
            }
            else if let user = user {
                self.view(for: user)
            }
            
            if users.count > 2 {
                ZStack {
                    Text(stringCount)
                        .font(.system(size: 11, weight: .semibold, design: .default))
                        .foregroundColor(status == .needAction ? Color(hex: "#858585") : titleColor)
                        .padding(.horizontal, count > 99 ? 4 : 2)
                        .frame(minWidth: 20)
                        .frame(height: 20)
                        .multilineTextAlignment(.center)
                        .background(status == .needAction ? Color(hex: "#EBECEF") : backgroundColor)
                        .clipShape(Capsule())
                        .overlay(Capsule().stroke(Color.Event.eventUserBorder, lineWidth: 2))
                        .accessibility(identifier: "UsersViewCountLabel")
                }
            }
        }
        .accessibility(identifier: "UsersView")
    }
    
    private func view(for user: User) -> some View {
        Group {
            if let urlString = user.imageURL , let url = URL(string: urlString) {
                URLImageView(url: url)
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 20, height: 20)
                    .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
                    .overlay(Circle().stroke(Color.Event.eventUserBorder, lineWidth: 1))
                    .accessibility(identifier: "UsersViewUserImage")
            }
            else {
                EmptyView()
            }
        }
    }
}

struct ButtonСallView: View {
    let url: String
    
    var body: some View {
        ZStack {
            Link(destination: URL(string: Constants.DeepLink.Event.url(url).url)!) {
                HStack(alignment: .center)  {
                    Image("button_camera_icon")
                        .padding(.leading, 12)
                        .padding(.top, 12)
                        .padding(.bottom, 12)
                        .accessibility(identifier: "ButtonСallViewIconImage")
                    Text("Присоединиться к звонку")
                        .font(.system(size: 13, weight: .medium, design: .default))
                        .foregroundColor(Color.buttonTextTitle)
                        .padding(.trailing, 18)
                        .accessibility(identifier: "ButtonСallViewTitleLabel")
                }
                .frame(height: 36)
            }
        }
        .background(Color.Event.buttonBackground)
        .cornerRadius(11)
        .padding(.top, 8)
        .accessibility(identifier: "ButtonСallView")
    }
}

struct ButtonsPendingView: View {
    
    let event: Event
    
    private struct ButtonData: Hashable {
        let title: String
        let scheme: String
        
        var url: URL {
            URL(string: self.scheme)!
        }
    }
    
    private var buttons: [ButtonData] {
        [.init(title: "Иду", scheme: Constants.DeepLink.Event.event(.yes, eventID: event.uid, calendarID: event.calendar.uid).url),
         .init(title: "Не иду", scheme: Constants.DeepLink.Event.event(.no, eventID: event.uid, calendarID: event.calendar.uid).url),
         .init(title: "Может быть", scheme: Constants.DeepLink.Event.event(.maybe, eventID: event.uid, calendarID: event.calendar.uid).url)]
    }
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(buttons, id: \.self) { button in
                ZStack {
                    Link(destination: button.url) {
                        Text(button.title)
                            .padding(.all, 10)
                            .font(.system(size: 13, weight: .medium, design: .default))
                            .accessibility(identifier: "ButtonsPendingViewButton")
                    }
                }
                .background(Color.Event.buttonBackground)
                .cornerRadius(11)
                .frame(height: 36)
            }
        }
        .padding(.top, 8)
        .accessibility(identifier: "ButtonsPendingView")
        
    }
}

struct TimeView: View {
    
    @Environment(\.colorScheme) var colorScheme
 
    let event: Event
    
    var titleColor: Color {
        Color.Event.Time.applyColor(originalColor: Color(hex: event.calendar.color), colorScheme: colorScheme)
    }
    
    var backgroundColor: Color {
        Color.Event.Time.applyColor(originalColor: Color(hex: event.calendar.color), colorScheme: colorScheme, reverse: true)
    }
    
    var body: some View {
        ZStack {
            if event.eventStatus == .maybe {
                Image("time_bg")
                    .renderingMode(.template)
                    .foregroundColor(backgroundColor)
            }
            Text(event.from.timeString)
                .font(.system(size: 11, weight: .semibold, design: .default))
                .foregroundColor(event.eventStatus == .needAction ? Color.Event.Time.borderDashPending : titleColor)
                .accessibility(identifier: "TimeViewTimeLabel")
        }
        .frame(width: 40, height: 22)
        .background(event.eventStatus == .needAction || event.eventStatus == .maybe ? Color.clear : backgroundColor)
        .cornerRadius(8)
        .if(event.eventStatus == .needAction || event.eventStatus == .maybe) {
            $0.overlay(
                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [2,2]))
                    .foregroundColor(event.eventStatus == .needAction ?
                                        Color.Event.Time.borderDashPending :
                                        backgroundColor)
            )
        }
        .accessibility(identifier: "TimeView")
        
    }
}

struct EventTextView: View {
    
    @Environment(\.colorScheme) var colorScheme

    let title: String
    let color: String
    let isBirthday: Bool
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            RoundedRectangle(cornerRadius: 2, style: .circular)
                .fill(Color.Event.Time.applyColor(originalColor: Color(hex: color), colorScheme: colorScheme, reverse: true))
                .frame(width: 4, height: 20)
            
            Text(isBirthday ? "День рождения \(title)" : title)
                .font(.system(size: 15, weight: .regular, design: .default))
                .foregroundColor(Color.buttonTextTitle)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibility(identifier: "EventTextViewTitleLabel")
        }
        .padding(.leading, 11)
        .padding(.trailing, 11)
        .accessibility(identifier: "EventTextView")
    }
}

struct EventDateHeaderView: View {
    let date: Date
        
    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            if DateFormatter.isDateRelative(date) {
                Text(DateFormatter.relativeDateFormatter(date) + ", ")
                    .font(.system(size: 13, weight: .medium, design: .default))
                    .foregroundColor(Color.buttonTextTitle)
                    .frame(height: 20)
                    .accessibility(identifier: "EventDateHeaderViewTextDateLabel")
                Text(DateFormatter.format(date, format: "d MMMM"))
                    .font(.system(size: 13, weight: .medium, design: .default))
                    .foregroundColor(Color.Event.Time.titlePending)
                    .frame(height: 20)
                    .accessibility(identifier: "EventDateHeaderViewDateLabel")
            }
            else {
                Text(DateFormatter.format(date, format: "d MMMM"))
                    .font(.system(size: 13, weight: .medium, design: .default))
                    .foregroundColor(Color.buttonTextTitle)
                    .frame(height: 20)
                    .accessibility(identifier: "EventDateHeaderViewDateLabel")
            }
        }
        .frame(height: 32)
        .padding(.leading, 11)
        .offset(x: 0, y: -5)
        .padding(.top, -5)
        .padding(.bottom, -15)
        .accessibility(identifier: "EventDateHeaderView")
    }
}
