import SwiftData
import SwiftUI

struct StoreListView: View {
   /// environment
   @Environment(\.modelContext) private var modelContext

   /// Standort-Auswahl
   @Query(sort: \Location.name) private var locations: [Location]
   @State private var selectedLocation: Location? = nil

   /// Alle Items (werden in-memory gefiltert)
   @Query(sort: \StoreItem.name) private var storeItems: [StoreItem]

   /// states
   @State private var showAddSheet = false

   /// In-Memory-Filter entsprechend der Standortauswahl
   private var filteredItems: [StoreItem] {
      guard let selectedLocation else { return storeItems }
      return storeItems.filter { $0.location.id == selectedLocation.id }
   }

   private var hasItems: Bool {
      !filteredItems.isEmpty
   }

   var body: some View {
      NavigationStack {
         Group {
            if hasItems || !locations.isEmpty {
               VStack(spacing: 0) {
                  if !locations.isEmpty {
                     Picker("Standort", selection: $selectedLocation) {
                        Text("Alle").tag(Optional<Location>(nil))
                        ForEach(locations) { location in
                           Text(location.name).tag(Optional(location))
                        }
                     }
                     .pickerStyle(.segmented)
                     .padding(.horizontal)
                     .padding(.top, 8)
                     .padding(.bottom, 4)
                  }

                  List {
                     ForEach(filteredItems) { item in
                        StoreRowView(item: item)
                     }
                     .onDelete(perform: deleteStoreItems)
                  }
                  .listStyle(.plain)
                  .scrollContentBackground(.hidden)
                  .scrollIndicators(.hidden)
                  .background(Color(.systemBackground))
               }
            } else {
               EmptyStateView {
                  showAddSheet = true
               }
            }
         }
         .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
               Button {
                  showAddSheet = true
               } label: {
                  Image(systemName: "plus")
               }
               .buttonStyle(.glassProminent)
            }
         }
         .sheet(isPresented: $showAddSheet) {
            StoreItemAddView()
         }
         .navigationTitle(titleText)
         .navigationBarTitleDisplayMode(.automatic)
         .navigationBarHidden(!hasItems)
      }
   }

   private var titleText: String {
      return "Artikel (\(filteredItems.count))"
   }

   private func deleteStoreItems(at offsets: IndexSet) {
      for index in offsets {
         modelContext.delete(filteredItems[index])
      }
   }
}

#Preview {
   StoreListView()
}
