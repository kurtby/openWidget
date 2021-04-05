//
//  EventDemo.swift
//  MRCalendarWidget
//
//  Created by Valentine Eyiubolu on 5.04.21.
//

import Foundation

extension Event {
    
    static func generateDemo() -> [Event] {
        
        let event1Date = Date()
        let nextUpdateDate: Date = Calendar.current.date(byAdding: .hour, value: 1, to: event1Date) ?? event1Date
        
        let event2Date: Date = Calendar.current.date(byAdding: .hour, value: 4, to: event1Date) ?? event1Date
        let nextUpdate2Date: Date = Calendar.current.date(byAdding: .hour, value: 2, to: event2Date) ?? event2Date
        
        var edges: [Edges] = []
        
        for _ in 0...14 {
            edges.append(Edges(node: Node(user: User(email: "valent-in@list.ru"))))
        }
        
        let event = Event(uid: UUID().uuidString, title: "Обсуждение планов", from: event1Date, to: nextUpdateDate, fullDay: false, recurrenceID: nil, status: "NEEDS_ACTION", calendar: .init(uid: UUID().uuidString, title: "Personal", color: "#9EDBFF", type: "PERSONAL"), call: nil, location: .init(description: "Видеозвонки Mail.ru"), access: "", attendeesCount: 14, attendeesConnection: .init(edges: edges), organizer: .init(email: "valent-in@list.ru"))
        
        let event2 = Event(uid: UUID().uuidString, title: "Запись к стоматологу", from: event2Date, to: nextUpdate2Date, fullDay: false, recurrenceID: nil, status: "ACCEPTED", calendar: .init(uid: UUID().uuidString, title: "Personal", color: "#9EDBFF", type: "PERSONAL"), call: nil, location: .init(description: "пр. Вернадского"), access: "", attendeesCount: 0, attendeesConnection: .init(edges: []), organizer: nil)
      
        return [event, event2]
    }
    
}
