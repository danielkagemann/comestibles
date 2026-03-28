//
//  QuantitySheet.swift
//  comestibles
//
//  Created by Daniel Kagemann on 28.03.26.
//
import SwiftUI

struct QuantitySheet: View {
    let item: StoreItem

    var body: some View {
        Text("Menge ändern").font(.title2).bold()
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
