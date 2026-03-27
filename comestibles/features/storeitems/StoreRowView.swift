//
//  StoreRowView.swift
//  comestibles
//
//  Created by Daniel Kagemann on 22.03.26.
//

import Kingfisher
import SwiftUI

struct StoreRowView: View {
    /// input
    let item: StoreItem

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            KFImage(URL(string: item.image ?? ""))
                .placeholder {
                    Circle()
                        .fill(Color(.systemGray5))
                        .overlay { Text("?") }
                }
                .resizable()
                .scaledToFill()
                .frame(width: 48, height: 48)
                .clipShape(Circle())
                .background {
                    GeometryReader { geo in
                        Path { path in
                            let x = geo.size.width / 2
                            path.move(to: CGPoint(x: x, y: -20))
                            path.addLine(to: CGPoint(x: x, y: geo.size.height + 20))
                        }
                        .stroke(Color(.systemGray3), style: StrokeStyle(lineWidth: 1, dash: [3, 2]))
                    }
                    .frame(width: 1)
                }

            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.headline)
                Text("Menge: \(item.quantity)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            ExpiryBadge(item: item)
        }
        .padding(.vertical, 4)
    }
}

private struct ExpiryBadge: View {
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
            .background(color.opacity(0.15))
            .foregroundStyle(color)
            .clipShape(Capsule())
    }
}

#Preview {
    let item = StoreItem(name: "Test", location: .init(name: "zuhause"))
    item.quantity = 5
    item.barcode = "12345"
    item.image = "https://images.openfoodfacts.org/images/products/848/000/022/3111/front_es.90.400.jpg"
    return StoreRowView(item: item)
}
