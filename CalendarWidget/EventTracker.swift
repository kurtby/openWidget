//
//  EventTracker.swift
//  MRCalendarWidget
//
//  Created by Valentine Eyiubolu on 7.04.21.
//

import Foundation

private extension Log.Categories {
    static let eventTracker: Self = "Widget.Calendar.EventTracker"
}

class EventTracker {
    
    enum EventType {
        case timeline(state: TimelineState)
        case request(_ request: APIRequestBuilder)
        case error(_ request: APIRequestBuilder, error: Error, code: Int)
        case navigate(_ route: String)
        
        enum TimelineState {
            case created(at: Date)
            case updated(at: Date)
        }
    }
    
    static let shared = EventTracker()
    
    private var events: [EventTrack] = []
    
    private let eventQueue = DispatchQueue(label: "widgetkit.tracker.serial.queue")
    
    private let logger = Log.createLogger(category: .eventTracker)
    
    public func track(_ event: EventTrack) {
        eventQueue.async {
            self.events.append(event)
            self.logger.log(level: .debug, "\(event)")
        }
    }
    
}

struct EventTrack: CustomStringConvertible {
    let name: EventTracker.EventType
    var additionalParameters: [String:AnyObject]?
    
    var description: String {
        switch name {
        case .timeline(let state):
            switch state {
            case .created(let at):
                return "Timeline created at: \(at)"
            case .updated(let at):
                return "Timeline updated at: \(at)"
            }
        case .request(let request):
            return "Request url \(request.baseURL), method: \(request.endpointDescription)"
        case .error(let request, let error, let code):
            return "Request ERROR: \(error.localizedDescription), code: \(code) url: \(request.baseURL), method: \(request.endpointDescription)"
        case .navigate(let url):
            return "Route pressed: \(url)"
        }
    }
}
