//
//  CalendarWidgetEntry.swift
//  CalendarWidgetExtension
//
//  Created by Valentine Eyiubolu on 19.02.21.
//

import WidgetKit

struct CalendarWidgetEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationIntent
    
    var data: Network.ResponseData = .init()
}
