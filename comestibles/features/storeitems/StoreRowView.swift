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

    @State private var showQuantitySheet = false

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
        .contentShape(Rectangle())
        .onTapGesture { showQuantitySheet = true }
        .sheet(isPresented: $showQuantitySheet) {
            QuantitySheet(item: item)
                .presentationDetents([.height(140)])
                .presentationDragIndicator(.visible)
        }
    }
}

private struct QuantitySheet: View {
    let item: StoreItem

    var body: some View {
       Text ("Menge ändern").font(.title2).bold()
        HStack(spacing: 32) {
            Button {
                if item.quantity > 0 { item.quantity -= 1 }
            } label: {
                Image(systemName: "minus.circle.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(item.quantity > 0 ? .primary : .tertiary)
            }
            .disabled(item.quantity <= 1)

            Text("\(item.quantity)")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .monospacedDigit()
                .frame(minWidth: 60, alignment: .center)

            Button {
                item.quantity += 1
            } label: {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(.primary)
            }
        }
        .padding(.top, 24)
        .frame(maxWidth: .infinity)
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
