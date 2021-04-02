//
//  CalendarWidgetDataProvider.swift
//  MRCalendarWidget
//
//  Created by Valentine Eyiubolu on 2.04.21.
//

import Foundation
import WidgetKit

class CalendarWidgetDataProvider {
    
    typealias Entry = CalendarWidgetEntry
    
    private let network = Network()
        
    public var configuration: ConfigurationIntent?
    public var context: TimelineProviderContext?
    public var completion: (Timeline<Entry>) -> () = { _ in }
}

extension CalendarWidgetDataProvider {
    
    public func run(configuration: ConfigurationIntent, context: TimelineProviderContext, completion: @escaping (Timeline<Entry>) -> ()) {
      
        self.configuration = configuration
        self.context = context
        self.completion = completion
     
        self.load()
    }

    private func load() {
        
        network.loadData { (data, error) in
            
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
                
                if let configuration = self.configuration {
                    var entry = CalendarWidgetEntry(date: updateDate, configuration: configuration)
                    entry.data = data
                    entries.append(entry)
                }
            }
            else if let configuration = self.configuration {
                var entry = CalendarWidgetEntry(date: nextUpdateDate, configuration: configuration)
                entry.data = data
                entries.append(entry)
            }

            let timeline = Timeline(entries: entries, policy: .atEnd)
            self.completion(timeline)
        }
    }
    
}


