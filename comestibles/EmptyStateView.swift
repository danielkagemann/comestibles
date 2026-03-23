//
//  EmptyStateView.swift
//  comestibles
//
//  Created by Daniel Kagemann on 22.03.26.
//


import SwiftUI

struct EmptyStateView: View {
   /// input
   var action: () -> Void
   
    var body: some View {
        ContentUnavailableView {
            Label(
                "Keine Lebensmittel",
                systemImage: "cart.badge.questionmark"
            )
        } description: {
            Text("Füge Lebensmittel mit einem Verfallsdatum hinzu.")
        } actions: {
           Button ("Hinzufügen") {
              action()
           }
           .buttonStyle(.glassProminent)
        }
    }
}

#Preview {
   EmptyStateView() {}
}
