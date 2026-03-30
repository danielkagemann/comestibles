//
//  Extension+Int.swift
//  laiba
//
//  Created by Daniel Kagemann on 25.07.23.
//

import Foundation

extension Int {
   func plural(single: String, multiple: String, prefixValue: Bool = false) -> String {
      if self == 1 {
         return prefixValue ? "\(self) \(single)" : single
      }
      return prefixValue ? "\(self) \(multiple)" : multiple
   }
   
   func smartDays() -> String {
      if self > 365 {
         let years = self / 365
         return String(localized: "in \(years) Jahr", table: "Localizable")
      }
      if self > 31 {
         let months = self / 31
         return String(localized: "in \(months) Monat", table: "Localizable")
      }
      if self > 7 {
         let weeks = self / 7
         return String(localized: "in \(weeks) Woche", table: "Localizable")
      }
      return String(localized: "in \(self) Tag", table: "Localizable")
   }
}
