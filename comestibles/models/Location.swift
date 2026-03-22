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

    var street: String?
    var postalCode: String?
    var city: String?
    var latitude: Double?
    var longitude: Double?

    @Relationship(deleteRule: .cascade, inverse: \StoreItem.location)
    var storeItems: [StoreItem] = []

    init(name: String, street: String? = nil, postalCode: String? = nil, city: String? = nil, latitude: Double? = nil, longitude: Double? = nil) {
        self.id = UUID()
        self.name = name
        self.street = street
        self.postalCode = postalCode
        self.city = city
        self.latitude = latitude
        self.longitude = longitude
    }
}
