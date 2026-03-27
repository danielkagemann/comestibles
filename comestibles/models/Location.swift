//
//  Location.swift
//  comestibles
//
//  Created by Daniel Kagemann on 22.03.26.
//

import Foundation
import SwiftData

@Model
final class Location {
   var id: UUID
   var name: String
   var address: String?
   var image: Data?

   @Relationship(deleteRule: .cascade, inverse: \StoreItem.location)
   var storeItems: [StoreItem] = []

   init(name: String, address: String? = nil, image: Data? = nil) {
      id = UUID()
      self.name = name
      self.address = address
      self.image = image
   }
}
