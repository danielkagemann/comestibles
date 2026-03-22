//
//  GroceryRowView.swift
//  comestibles
//
//  Created by Daniel Kagemann on 22.03.26.
//


import SwiftUI

struct GroceryRowView: View {
    let item: GroceryItem

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(item.name)
                    .font(.headline)
                Spacer()
                ExpiryBadge(item: item)
            }
            HStack(spacing: 12) {
                Label(item.location.name, systemImage: "mappin.circle")
                if let barcode = item.barcode {
                    Label(barcode, systemImage: "barcode")
                }
                Label("Qty: \(item.quantity)", systemImage: "number")
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}

private struct ExpiryBadge: View {
    let item: GroceryItem

    var body: some View {
        let days = item.daysUntilExpiry
        let color: Color = item.isExpired ? .red : days <= 3 ? .orange : .green
        let label = item.isExpired ? "Expired" : days == 0 ? "Today" : "in \(days)d"

        Text(label)
            .font(.caption2.bold())
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(color.opacity(0.15))
            .foregroundStyle(color)
            .clipShape(Capsule())
    }
}