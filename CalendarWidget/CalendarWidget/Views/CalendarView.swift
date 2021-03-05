//
//  CalendarView.swift
//  CalendarWidgetExtension
//
//  Created by Valentine Eyiubolu on 8.02.21.
//

import SwiftUI

struct CalendarView<DateView>: View where DateView: View {
    
    init(@ViewBuilder content: @escaping (Date) -> DateView) {
        self.content = content
    }

    @Environment(\.calendar) var calendar

    let content: (Date) -> DateView
    
    @ViewBuilder
    var body: some View {
        VStack(alignment: .center, spacing: 7) {
            headerMonthView() 
            weekDaysView()
            daysGridView()
        }
        .padding(.vertical, 13)
    }
    
    // MARK: Private
    private func headerMonthView() -> some View {
    
        var monthTitle: String {
            
            let days = calendar.days()
            
            guard let firstDate = days.first , let endDate = days.last , !days.isEmpty else {
                return ""
            }
            
            if calendar.isDate(firstDate, equalTo: endDate, toGranularity: .month) {
                let firstMonth = DateFormatter.month.string(from: firstDate).localizedUppercase
                return firstMonth
            }
            else {
                let firstMonth = DateFormatter.month.string(from: firstDate).localizedUppercase
                let secondMonth = DateFormatter.month.string(from: endDate).localizedUppercase
                
                return firstMonth + " - " + secondMonth
            }
        }
        
        return HStack {
            Text(monthTitle)
                .font(.system(size: 11, weight: .medium, design: .default))
                .foregroundColor(Color.Calendar.headerTitle)
            Spacer()
        }
        .padding(.leading, 21)
    }
    
    private func weekDaysView() -> some View {
        HStack(spacing: 4) {
            ForEach(0 ..< 7, id: \.self) { index in
                Text(weekDaysSorted()[index].localizedUppercase)
                    .font(.system(size: 8, weight: .medium, design: .default))
                    .scaledToFill()
                    .foregroundColor(Color.Calendar.weekDayTitle)
                    .frame(width: 16, height: 16, alignment: .center)
            }
        }
        .padding(.leading, 16)
    }
    
    private func daysGridView() -> some View {
        LazyVGrid(columns: Array(repeating: GridItem(.fixed(20), spacing: 0, alignment: .center), count: 7), spacing: 2) {
            ForEach(calendar.days(), id: \.self) { date in
                content(date).id(date)
            }
        }
        .padding(.leading, 16)
    }
    
    private func weekDaysSorted() -> [String] {
        var weekDays = Calendar.current.veryShortWeekdaySymbols
        
        // Need to cut last character because of design style in ru locale
        if let locale = Locale.current.languageCode , locale == "ru" {
            weekDays = weekDays.map { String($0.dropLast()) }
        }
        
        let sortedWeekDays = Array(weekDays[Calendar.current.firstWeekday - 1 ..< Calendar.current.shortWeekdaySymbols.count] + weekDays[0 ..< Calendar.current.firstWeekday - 1])
        return sortedWeekDays
    }
    
}
