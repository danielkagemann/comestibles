//
//  ExpiryBadge.swift
//  comestibles
//
//  Created by Daniel Kagemann on 28.03.26.
//

import SwiftUI

struct ExpiryBadge: View {
    /// input
    let item: StoreItem

    var body: some View {
        let days = item.daysUntilExpiry
        let color: Color = item.isExpired ? .red : days <= 3 ? .orange : .green
        let label = item.isExpired ? "Abgelaufen" : days == 0 ? "heute" : days.smartDays()

        Text(label)
            .font(.caption2.bold())
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(color.opacity(0.1))
            .foregroundStyle(color)
            .clipShape(Capsule())
    }
}
