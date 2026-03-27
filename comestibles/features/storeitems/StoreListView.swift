import SwiftData
import SwiftUI

struct StoreListView: View {
   /// environment
   @Environment(\.modelContext) private var modelContext

   /// required location
   var location: Location 

   /// queries
   @Query(sort: \StoreItem.name) private var storeItems: [StoreItem]

   /// states
   @State private var showAddSheet = false

   // derived state for in memory filtering
   private var filteredItems: [StoreItem] {
      storeItems.filter { $0.location.id == location.id }
   }

   private var hasItems: Bool {
      !filteredItems.isEmpty
   }

   var body: some View {
      Group {
         if hasItems {
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
         } else {
            // TODO EmptyStateView
         }
      }
      .navigationTitle("\(location.name) (\(filteredItems.count))")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
         ToolbarItem(placement: .navigationBarTrailing) {
            Button {
               showAddSheet = true
            } label: {
               Text("Neu").font(.callout)
            }
            .buttonStyle(.glassProminent)
         }
      }
      .sheet(isPresented: $showAddSheet) {
         StoreItemAddView()
      }
   }

   private func deleteStoreItems(at offsets: IndexSet) {
      for index in offsets {
         modelContext.delete(filteredItems[index])
      }
   }
}
