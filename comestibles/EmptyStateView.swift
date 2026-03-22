//
//  EmptyStateView.swift
//  comestibles
//
//  Created by Daniel Kagemann on 22.03.26.
//


import SwiftUI

struct EmptyStateView: View {
    let tab: ItemListView.ItemTab

    var body: some View {
        ContentUnavailableView {
            Label(
                tab == .grocery ? "No Food Items" : "No Store Items",
                systemImage: tab == .grocery ? "cart.badge.questionmark" : "shippingbox"
            )
        } description: {
            Text(tab == .grocery
                 ? "Add food items with an expiry date to track freshness."
                 : "Add items to keep track of your inventory.")
        } actions: {
            // The + button in the toolbar handles adding,
            // but you can also add a shortcut here:
            // Button("Add Item") { }
        }
    }
}