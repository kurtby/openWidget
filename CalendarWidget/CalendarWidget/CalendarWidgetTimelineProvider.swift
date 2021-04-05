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
            entry.data.events = Event.generateDemo()
            completion(entry)
        }
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        CalendarWidgetDataProvider().getTimeline(configuration: configuration, context: context, completion: completion)
    }
    
}
