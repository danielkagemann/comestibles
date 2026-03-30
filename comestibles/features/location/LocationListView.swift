//
//  LocationListView.swift
//  comestibles
//
//  Created by Daniel Kagemann on 27.03.26.
//

import SwiftData
import SwiftUI

struct LocationListView: View {
   /// environment
   @Environment(\.modelContext) private var modelContext

   /// states
   @State private var showLocation: Bool = false
   @State private var selectedLocation: Location? = nil
   @State private var locationToDelete: Location? = nil
   @State private var locationToEdit: Location? = nil

   /// queries
   @Query private var locations: [Location]
   @Query private var storeItems: [StoreItem]

   @ViewBuilder fileprivate func Empty() -> some View {
      if locations.isEmpty {
         ContentUnavailableView {
            Image(systemName: "mappin.slash.circle")
               .font(.system(size: 72))
               .foregroundStyle(.secondary)
            Text("Kein Standort", tableName: "Localizable")
               .font(.title2)
               .fontWeight(.semibold)
         } description: {
            Text("Es ist noch kein Standort vorhanden.", tableName: "Localizable")
         } actions: {
            Button(String(localized: "Hinzufügen")) {
               showLocation = true
            }
            .buttonStyle(.glassProminent)
         }
      }
   }

   @ViewBuilder fileprivate func Content() -> some View {
      if !locations.isEmpty {
         List {
            ForEach(locations) { loc in
               LocationRowItem(item: loc, count: storeItems.count(where: {$0.location.id == loc.id}))
                  .contentShape(Rectangle())
                  .onTapGesture { selectedLocation = loc }
                  .listRowBackground(Color.clear)
                  .listRowSeparator(.hidden)
                  .swipeActions(edge: .leading, allowsFullSwipe: false) {
                     Button {
                        locationToEdit = loc
                     } label: {
                        Label(String(localized: "Bearbeiten"), systemImage: "pencil")
                     }
                     .tint(.accentColor)
                  }
                  .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                     Button(role: .destructive) {
                        locationToDelete = loc
                     } label: {
                        Label(String(localized: "Löschen"), systemImage: "trash")
                     }
                  }
            }
         }
         .listStyle(.plain)
         .scrollContentBackground(.hidden)
         .scrollIndicators(.hidden)
         .background(Color(.systemBackground))
      }
   }

   var body: some View {
      Group {
         Empty()
         Content()
            .navigationDestination(item: $selectedLocation) { location in
               StoreListView(location: location)
            }
      }
      .toolbar {
         ToolbarItem(placement: .navigationBarTrailing) {
            Button {
               showLocation = true
            } label: {
               Text("Neu", tableName: "Localizable").font(.callout)
            }
            .buttonStyle(.glassProminent)
         }
      }
      .navigationBarTitleDisplayMode(.inline)
      .navigationBarHidden(locations.isEmpty)
      .sheet(isPresented: $showLocation) {
         LocationAddView()
      }
      .sheet(item: $locationToEdit) { loc in
         LocationAddView(editLocation: loc)
      }
      .confirmationDialog(
         String(localized: "Standort löschen?"),
         isPresented: Binding(get: { locationToDelete != nil }, set: { if !$0 { locationToDelete = nil } }),
         titleVisibility: .visible
      ) {
         Button(String(localized: "Löschen"), role: .destructive) { confirmDelete() }
         Button(String(localized: "Abbrechen"), role: .cancel) { locationToDelete = nil }
      } message: {
         if let name = locationToDelete?.name {
            Text(String(format: String(localized: "\"%@\" und alle zugehörigen Artikel werden unwiderruflich gelöscht."), name))
         }
      }
   }

   private func confirmDelete() {
      guard let location = locationToDelete else { return }
      modelContext.delete(location)
      locationToDelete = nil
   }
}

#Preview {
   LocationListView()
}
