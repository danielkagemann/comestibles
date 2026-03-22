//
//  Item.swift
//  comestibles
//
//  Created by Daniel Kagemann on 22.03.26.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
