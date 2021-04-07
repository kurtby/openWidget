//
//  CalendarWidgetDataProvider.swift
//  MRCalendarWidget
//
//  Created by Valentine Eyiubolu on 2.04.21.
//

import Foundation
import WidgetKit
import os

private extension Log.Categories {
    static let calendarWidgetDataProvider: Self = "Widget.Calendar.DataProvider"
}

class CalendarWidgetDataProvider {
    
    typealias Entry = CalendarWidgetEntry
    typealias TimelineBlock = (Timeline<Entry>) -> ()
    
    private let network = Network()
    private let logger = Log.createLogger(category: .calendarWidgetDataProvider)
    
    public var configuration: ConfigurationIntent?
    public var context: TimelineProviderContext?
    public var completion: TimelineBlock?
    
    public func getTimeline(configuration: ConfigurationIntent, context: TimelineProviderContext, completion: @escaping TimelineBlock) {
      
        self.configuration = configuration
        self.context = context
        self.completion = completion
        
        self.load()
    }
    
}

extension CalendarWidgetDataProvider {
    
    private func load() {
     
        network.loadData(Event.RequestParameters(from: Date())) { (data, error) in
            
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
                
                self.logger.log(level: .debug, "Next Timeline Update: \(updateDate)")
                self.logger.log(level: .debug, "Next Event Start: \(nextEvent.from)")
                self.logger.log(level: .debug, "Next Event finish: \(nextEvent.to)")
                
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
            self.completion?(timeline)
        }
    }
    
}
