//
//  StringFormatter+DateTime.swift
//  Fasting
//
//  Created by Zach McGaughey on 4/22/21.
//

import Foundation

public extension StringFormatter {
  
  /// Format a date in to a human readable format.
  /// - Parameters:
  ///   - date: The date to format
  ///   - separator:
  ///   An optional separator. This separator will be used when more than just the time is displayed.
  ///   For instance if this value is '`at`' the string would format to: Tomorrow **at** 1:00 pm
  ///   - capitalized: If true, the string will be capitalized upon return.
  /// - Returns: A human readable String referencing the Date provided.
  static func colloquialDateTime(
    from date: Date,
    separator: String? = nil,
    capitalized: Bool = true
  ) -> String {

    let timeString: String = timeFormatter.string(from: date)

    // If the date is today, we don't need to show any other info than time
    if date.isToday {
      return timeString
    }

    // We need to figure out what date string to use that makes sense.
    // If it's within the same week or two as now we can refer to it as the weekday name
    // If it's outside of a two week span, we'll refer to it simply by the numerical date
    var dayString: String

    if date.isTomorrow {
      dayString = "tomorrow"

    } else if date.isYesterday {
      dayString = "yesterday"

    } else if date.isInside(date: Date(), granularity: .weekOfYear) {
      dayString = date.toFormat("EEEE")

    } else if date.isInside(date: Date().dateByAdding(-1, .weekOfYear).date, granularity: .weekOfYear) {
      dayString = "last \(date.toFormat("EEEE"))"

    } else if date.isInside(date: Date().dateByAdding(1, .weekOfYear).date, granularity: .weekOfYear) {
      dayString = "next \(date.toFormat("EEEE"))"

    } else {
      dayString = shortDateFormatter.string(from: date)
    }
    
    if capitalized {
      dayString = dayString.capitalized
    }
    
    if let separator = separator {
      return "\(dayString) \(separator) \(timeString)"
      
    } else {
      return "\(dayString) \(timeString)"
    }

  }
  
}
