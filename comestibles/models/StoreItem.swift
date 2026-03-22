//
//  GroceryItem.swift
//  comestibles
//
//  Created by Daniel Kagemann on 22.03.26.
//


import Foundation
import SwiftData

@Model
final class GroceryItem {
    var id: UUID
    var name: String
    var barcode: String?
    var dueDate: Date
    var quantity: Int
    var notes: String?
    var createdAt: Date

    var location: Location  // ← non-optional

    init(
        name: String,
        location: Location,  // ← required
        barcode: String? = nil,
        dueDate: Date,
        quantity: Int = 1,
        notes: String? = nil
    ) {
        self.id = UUID()
        self.name = name
        self.barcode = barcode
        self.dueDate = dueDate
        self.quantity = quantity
        self.notes = notes
        self.createdAt = Date.now
        self.location = location
    }

    var isExpired: Bool { dueDate < Date.now }
    var daysUntilExpiry: Int {
        Calendar.current.dateComponents([.day], from: Date.now, to: dueDate).day ?? 0
    }
}