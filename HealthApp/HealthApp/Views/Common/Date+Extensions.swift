//
//  Date+Extensions.swift
//  HealthApp
//
//  Created by Jared Davidson on 3/12/24.
//

import Foundation

extension Date {
    func formatDateWithOrdinal() -> String {
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "d"
        
        let monthFormatter = DateFormatter()
        monthFormatter.dateFormat = "MMMM"
        
        let day = Int(dayFormatter.string(from: self))!
        let month = monthFormatter.string(from: self)
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .ordinal
        let dayOrdinal = numberFormatter.string(from: NSNumber(value: day))!
        
        return "\(month) \(dayOrdinal)"
    }
    
    func isSameDay(as otherDate: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.isDate(self, inSameDayAs: otherDate)
    }
}
