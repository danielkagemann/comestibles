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
   @State private var searchText = ""

   // derived state for in memory filtering
   private var filteredItems: [StoreItem] {
      let locationItems = storeItems.filter { $0.location.id == location.id }
      guard !searchText.isEmpty else { return locationItems }
      return locationItems.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
   }

   private var hasItems: Bool {
      !filteredItems.isEmpty
   }

   // items grouped by store name, unsorted items go to "Sonstiges"
   private var groupedItems: [(store: String, items: [StoreItem])] {
      var dict: [String: [StoreItem]] = [:]
      for item in filteredItems {
         let store = item.stores?.trimmingCharacters(in: .whitespaces).isEmpty == false
            ? item.stores!.trimmingCharacters(in: .whitespaces)
            : "Sonstiges"
         dict[store, default: []].append(item)
      }
      return dict
         .map { (store: $0.key, items: $0.value) }
         .sorted { lhs, rhs in
            if lhs.store == "Sonstiges" { return false }
            if rhs.store == "Sonstiges" { return true }
            return lhs.store < rhs.store
         }
   }
   
   @ViewBuilder fileprivate func Empty() -> some View {
      ContentUnavailableView {
         Image(systemName: "cart.badge.questionmark")
            .font(.system(size: 72))
            .foregroundStyle(.secondary)
         Text("Keine Artikel")
            .font(.title2)
            .fontWeight(.semibold)
      } description: {
         Text("Keine Artikel vorhanden.")
      } actions: {
         Button("Hinzufügen") {
            showAddSheet = true
         }
      }
   }

   var body: some View {
      contentView
         .searchable(text: $searchText, prompt: "Artikel suchen")
         .navigationTitle("\(location.name) (\(filteredItems.count))")
         .navigationBarTitleDisplayMode(.inline)
         .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
               if !filteredItems.isEmpty {
                  Button {
                     showAddSheet = true
                  } label: {
                     Text("Neu").font(.callout)
                  }
                  .buttonStyle(.glassProminent)
               }
            }
         }
         .sheet(isPresented: $showAddSheet) {
            StoreItemAddView(location: location)
         }
   }

   @ViewBuilder private var contentView: some View {
      if hasItems {
         itemList
      } else {
         Empty()
      }
   }

   private var itemList: some View {
      List {
         ForEach(groupedItems, id: \.store) { group in
            Section(group.store) {
               ForEach(group.items) { item in
                  StoreRowView(item: item)
                     .listRowSeparator(.hidden)
               }
               .onDelete { offsets in deleteItems(in: group.items, at: offsets) }
            }
         }
      }
      .listStyle(.plain)
      .scrollContentBackground(.hidden)
      .scrollIndicators(.hidden)
      .background(Color(.systemBackground))
   }

   private func deleteItems(in items: [StoreItem], at offsets: IndexSet) {
      for index in offsets {
         modelContext.delete(items[index])
      }
   }
}
