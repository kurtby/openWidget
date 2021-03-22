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
            entry.data.weather = weather
            completion(entry)
        }
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        
        Network().loadData { (data, error) in
            print("events", data.events?.first, error)
            print("weather", data.weather, error)
            
            var entries: [CalendarWidgetEntry] = []
            
            // Update every (n) minutes
            let now = Date()
            let interval: Int = Constants.Timing.updateInterval
            let nextUpdateDate: Date = Calendar.current.date(byAdding: .minute, value: interval, to: now) ?? now
            
            if let events = data.events , let nextEvent = events.filter({$0.fullDay == false}).sorted(by: {$0.from < $1.from}).first {
                
                var updateDate = nextUpdateDate
                
                // If call in next event, update earlier to show button
                if let _ = nextEvent.call {
                    if let fromDate: Date = Calendar.current.date(byAdding: .minute, value: Constants.Timing.callOffsetInterval, to: nextEvent.from) , fromDate > now {
                        updateDate = fromDate
                    }
                }
                // If event end earlier then update interval
                else if let minutes = Calendar.current.dateComponents([.minute], from: now, to: nextEvent.to).minute , minutes < interval {
                    updateDate = nextEvent.to
                }
                
                print("NEXT UPDATE:-->>", updateDate, nextEvent.from, nextEvent.to)
    
                var entry = CalendarWidgetEntry(date: updateDate, configuration: configuration)
                entry.data = data
                entries.append(entry)
            }
            else {
                var entry = CalendarWidgetEntry(date: nextUpdateDate, configuration: configuration)
                entry.data = data
                entries.append(entry)
            }
            #warning("check for no connection?")
            
            let timeline = Timeline(entries: entries, policy: .atEnd)
            completion(timeline)
        }
        
    }
}
