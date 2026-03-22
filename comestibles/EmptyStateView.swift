//
//  EmptyStateView.swift
//  comestibles
//
//  Created by Daniel Kagemann on 22.03.26.
//


import SwiftUI

struct EmptyStateView: View {
    
    var body: some View {
        ContentUnavailableView {
            Label(
                "Keine Lebensmittel",
                systemImage: "cart.badge.questionmark"
            )
        } description: {
            Text("Fügen Sie Lebensmittel mit einem Verfallsdatum hinzu, um die Frische zu gewährleisten.")
        } actions: {
            // no actions
        }
    }
}
