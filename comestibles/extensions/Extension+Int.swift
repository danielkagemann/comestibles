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
         return "in " + (self / 365).plural(single: "Jahr", multiple: "Jahren", prefixValue: true)
      }
      if self > 31 {
         return "in " + (self / 31).plural(single: "Monat", multiple: "Monaten", prefixValue: true)
      }
      if self > 7 {
         return "in " + (self / 7).plural(single: "Woche", multiple: "Wochen", prefixValue: true)
      }
      return "in " + self.plural(single: "Tag", multiple: "Tagen", prefixValue: true)
   }
}
