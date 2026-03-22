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

    @Relationship(deleteRule: .cascade, inverse: \StoreItem.location)
    var storeItems: [StoreItem] = []

    init(name: String) {
        self.id = UUID()
        self.name = name
    }
}
