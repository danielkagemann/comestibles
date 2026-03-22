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
}
