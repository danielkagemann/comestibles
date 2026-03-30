//
//  GroceryItem.swift
//  comestibles
//
//  Created by Daniel Kagemann on 22.03.26.
//

import Foundation
import SwiftData

@Model
final class StoreItem {
   var id: UUID
   var name: String
   var barcode: String?
   var dueDate: Date?
   var quantity: Int
   var createdAt: Date
   var stores: String?
   var image: String?

   var location: Location // ← non-optional

   init(
      name: String,
      location: Location, // ← required
      barcode: String? = nil,
      dueDate: Date? = nil,
      quantity: Int = 1,
      stores: String? = nil,
      image: String? = nil
   ) {
      id = UUID()
      self.name = name
      self.barcode = barcode
      self.dueDate = dueDate
      self.quantity = quantity
      createdAt = Date.now
      self.location = location
      self.stores = stores
      self.image = image
   }

   var isExpired: Bool {
      guard let dueDate else { return true }
      return dueDate < Date.now
   }

   var daysUntilExpiry: Int {
      guard let dueDate else { return 0 }
      return Calendar.current.dateComponents([.day], from: Date.now, to: dueDate).day ?? 0
   }
}
