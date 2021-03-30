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
        VStack(alignment: .leading, spacing: 0) {
            headerMonthView()
            weekDaysView()
            daysGridView()
        }
        .padding(.top, 10)
        .padding(.leading, 10)
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
                .accessibility(identifier: "HeaderMonthViewTitleLabel")
            Spacer()
        }
        .frame(height: 16)
        .accessibility(identifier: "HeaderMonthView")
    }
    
    private func weekDaysView() -> some View {
        HStack(spacing: 1) {
            ForEach(0 ..< 7, id: \.self) { index in
                Text(weekDaysSorted()[index].localizedUppercase)
                    .font(.system(size: 9, weight: .medium, design: .default))
                    .scaledToFill()
                    .foregroundColor(Color.Calendar.weekDayTitle)
                    .frame(width: 20, height: 20, alignment: .center)
            }
        }
        .padding(.top, 4)
    }
    
    private func daysGridView() -> some View {
        LazyVGrid(columns: Array(repeating: GridItem(.fixed(20), spacing: 1, alignment: .center), count: 7), alignment: .leading, spacing: 2) {
            ForEach(calendar.days(), id: \.self) { date in
                content(date).id(date)
            }
        }
        .padding(.bottom, 4)
    }
    
    private func weekDaysSorted() -> [String] {
        let weekDays = Calendar.current.veryShortStandaloneWeekdaySymbols
        
        let sortedWeekDays = Array(weekDays[Calendar.current.firstWeekday - 1 ..< Calendar.current.shortWeekdaySymbols.count] + weekDays[0 ..< Calendar.current.firstWeekday - 1])
        return sortedWeekDays
    }
    
}
