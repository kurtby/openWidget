//
//  CalendarWidgetTimelineProvider.swift
//  CalendarWidgetExtension
//
//  Created by Valentine Eyiubolu on 15.02.21.
//

import Foundation
import WidgetKit

struct CalendarWidgetTimelineProvider: IntentTimelineProvider {
    
    typealias Entry = CalendarWidgetEntry
    
    func placeholder(in context: Context) -> Entry {
        CalendarWidgetEntry(date: Date(), configuration: ConfigurationIntent())
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Entry) -> ()) {
        
        Network().loadWeather { (weather, error) in
            var entry = CalendarWidgetEntry(date: Date(), configuration: configuration)
            entry.weather = weather
            completion(entry)
        }
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        
        Network().loadData { (data, error) in
            print("events", data.events?.first, error)
            print("weather", data.weather, error)
            
            var entries: [CalendarWidgetEntry] = []
            let nextHourFromNow = Calendar.current.date(byAdding: .hour, value: 1, to: Date()) ?? Date()
            
            if let events = data.events , let eventEndDate = events.filter({$0.fullDay == false}).sorted(by: {$0.from < $1.from}).map({$0.to}).first {
            
                var nextUpdateDate: Date = eventEndDate
                
                // Check if next update will be more then 1 hour, if yes update earlier
                if let minutes = Calendar.current.dateComponents([.minute], from: Date(), to: eventEndDate).minute , minutes > 60 {
                    nextUpdateDate = nextHourFromNow
                }
                
                print("First event end:\(eventEndDate)", "NEXT UPDATE", nextUpdateDate)
                
                var entry = CalendarWidgetEntry(date: nextUpdateDate, configuration: configuration)
                entry.weather = data.weather
                entry.events = data.events
                entries.append(entry)
            }
            else {
                var entry = CalendarWidgetEntry(date: nextHourFromNow, configuration: configuration)
                entry.weather = data.weather
                entry.events = data.events
                entries.append(entry)
            }
            #warning("check for no connection?")
            
            let timeline = Timeline(entries: entries, policy: .atEnd)
            completion(timeline)
        }
        
    }
}
