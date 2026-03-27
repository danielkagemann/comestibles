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

   /// queries
   @Query private var locations: [Location]

   @ViewBuilder fileprivate func Empty() -> some View {
      if locations.isEmpty {
         ContentUnavailableView {
            Image(systemName: "mappin.slash.circle")
               .font(.system(size: 72))
               .foregroundStyle(.secondary)
            Text("Kein Standort")
               .font(.title2)
               .fontWeight(.semibold)
         } description: {
            Text("Es ist noch kein Standort vorhanden.")
         } actions: {
            Button("Hinzufügen") {
               showLocation = true
            }
         }
      }
   }

   @ViewBuilder fileprivate func Content() -> some View {
      if !locations.isEmpty {
         List {
            ForEach(locations) { item in
               LocationRowItem(item: item, count: locations.count(where: {$0.id == item.id}))
                  .contentShape(Rectangle())
                  .onTapGesture { selectedLocation = item }
                  .listRowBackground(Color.clear)
            }
            .listRowSeparator(.hidden)
            
            // TODO delete with confirmation because all items will be deleted too
            // .onDelete(perform: deleteStoreItems)
         }
         .listStyle(.plain)
         .scrollContentBackground(.hidden)
         .scrollIndicators(.hidden)
         .background(Color(.systemBackground))
      }
   }

   var body: some View {
      NavigationStack {
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
               Text("Neu").font(.callout)
            }
            .buttonStyle(.glassProminent)
         }
      }
      .sheet(isPresented: $showLocation) {
         LocationAddView()
      }
      .navigationTitle("Standorte")
      .navigationBarTitleDisplayMode(.inline)
      .navigationBarHidden(!locations.isEmpty)
   }

   private func deleteStoreItems(at offsets: IndexSet) {
      for index in offsets {
         modelContext.delete(locations[index])
      }
   }
}

#Preview {
   LocationListView()
}
