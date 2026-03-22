import Foundation
import SwiftData

@Model
final class StoreItem {
    var id: UUID
    var name: String
    var category: String?
    var quantity: Int
    var isPurchased: Bool
    var notes: String?
    var createdAt: Date

    var location: Location  // ← non-optional

    init(
        name: String,
        location: Location,  // ← required
        category: String? = nil,
        quantity: Int = 1,
        notes: String? = nil
    ) {
        self.id = UUID()
        self.name = name
        self.category = category
        self.quantity = quantity
        self.isPurchased = false
        self.notes = notes
        self.createdAt = Date.now
        self.location = location
    }
}