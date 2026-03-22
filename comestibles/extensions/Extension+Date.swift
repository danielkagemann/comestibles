//
//  Extension+Date.swift
//  myorders
//
//  Created by Daniel Kagemann on 26.08.23.
//

import Foundation

extension Date {
   var month: String {
      let dateFormatter = DateFormatter()
      dateFormatter.locale = Locale.current
      dateFormatter.dateFormat = "MMMM"
      return dateFormatter.string(from: self)
   }
   
   func days (to: Date) -> Int {
      let differ = to.timeIntervalSince1970 - self.timeIntervalSince1970
      return Int(differ / 86400)
   }
   
   var date: String {
      let dateFormatter = DateFormatter()
      dateFormatter.dateFormat = "dd"
      return dateFormatter.string(from: self)
   }
   
   var monthName: String {
      let dateFormatter = DateFormatter()
      dateFormatter.locale = Locale.current
      dateFormatter.dateFormat = "MMMM"
      return dateFormatter.string(from: self)
   }
   
   /**
    get day of week where 1=monday...7=sunday
    */
   func dayInWeek () -> Int {
      let day = Calendar.current.dateComponents([.weekday], from: self).weekday ?? 1
      return day == 1 ? 7 : day - 1
   }
   
   /**
    get start of week for fiven date (week starts with monday
    */
   func startOfWeek() -> Date {
      let currentDay = self.dayInWeek()
      var comp = DateComponents()
      comp.day = 1 - currentDay
      return Calendar.current.date(byAdding: comp, to: self) ?? self
   }
   
   /**
    get end of week for fiven date (week starts with monday
    */
   func endOfWeek() -> Date {
      let currentDay = self.dayInWeek()
      var comp = DateComponents()
      comp.day = 7 - currentDay
      return Calendar.current.date(byAdding: comp, to: self) ?? self
   }
   
   /**
    navigation week forward or backward
    */
   func navigate (byDays: Int) -> Date {
      var comp = DateComponents()
      comp.day = byDays
      return Calendar.current.date(byAdding: comp, to: self) ?? self
   }
   
   /**
    get date in german timezone
    */
   func toGermanTimezone() -> Date {
      let timeZone = TimeZone(identifier: "Europe/Berlin")!
      
      // 1) Get the current TimeZone's seconds from GMT. Since I am in Chicago this will be: 60*60*5 (18000)
      let timezoneOffset =  timeZone.secondsFromGMT()
      
      // 2) Get the current date (GMT) in seconds since 1970. Epoch datetime.
      let epochDate = self.timeIntervalSince1970
      
      // 3) Perform a calculation with timezoneOffset + epochDate to get the total seconds for the
      //    local date since 1970.
      //    This may look a bit strange, but since timezoneOffset is given as -18000.0, adding epochDate and timezoneOffset
      //    calculates correctly.
      let timezoneEpochOffset = (epochDate + Double(timezoneOffset))
      
      // 4) Finally, create a date using the seconds offset since 1970 for the local date.
      return Date(timeIntervalSince1970: timezoneEpochOffset)
   }
   
   func toFormat(_ format: String) -> String {
      let formatter = DateFormatter()
      formatter.locale = Locale(identifier: "de")
      formatter.dateFormat = format
      return formatter.string(from: self)
   }
   
   static func isTimeForReview() -> Bool {
      let currentYear = Calendar.current.component(.year, from: Date())
      let today = Date()
      let reviewStartDate = Calendar.current.date(from: DateComponents(year: currentYear, month: 12, day: 15))!
      
      return today > reviewStartDate
   }
}
