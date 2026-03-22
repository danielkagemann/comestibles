//
//  Extension+Binding.swift
//  laiba
//
//  Created by Daniel Kagemann on 21.06.23.
//

import Foundation
import SwiftUI

extension Binding {
   func onChange(_ handler: @escaping (Value) -> Void) -> Binding<Value> {
      Binding(
         get: { self.wrappedValue },
         set: { newValue in
            self.wrappedValue = newValue
            handler(newValue)
         }
      )
   }
}
