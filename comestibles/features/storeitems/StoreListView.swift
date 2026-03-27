import SwiftData
import SwiftUI

private enum GroupingMode: String, CaseIterable {
   case store = "Geschäft"
   case expiry = "Ablaufdatum"
}

private enum ExpiryBucket: String, CaseIterable {
   case week = "≤ 7 Tage"
   case month = "≤ 1 Monat"
   case quarter = "≤ 3 Monate"
   case other = "> 3 Monate"

   static func bucket(for item: StoreItem) -> ExpiryBucket {
      guard let _ = item.dueDate, !item.isExpired else { return .other }
      let days = item.daysUntilExpiry
      if days <= 7 { return .week }
      if days <= 30 { return .month }
      if days <= 90 { return .quarter }
      return .other
   }
}

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
   @State private var groupingMode: GroupingMode = .store

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
   private var groupedByStore: [(key: String, items: [StoreItem])] {
      var dict: [String: [StoreItem]] = [:]
      for item in filteredItems {
         let store = item.stores?.trimmingCharacters(in: .whitespaces).isEmpty == false
            ? item.stores!.trimmingCharacters(in: .whitespaces)
            : "Sonstiges"
         dict[store, default: []].append(item)
      }
      return dict
         .map { (key: $0.key, items: $0.value) }
         .sorted { lhs, rhs in
            if lhs.key == "Sonstiges" { return false }
            if rhs.key == "Sonstiges" { return true }
            return lhs.key < rhs.key
         }
   }

   // items grouped by expiry bucket in fixed order
   private var groupedByExpiry: [(key: String, items: [StoreItem])] {
      var dict: [ExpiryBucket: [StoreItem]] = [:]
      for item in filteredItems {
         let bucket = ExpiryBucket.bucket(for: item)
         dict[bucket, default: []].append(item)
      }
      return ExpiryBucket.allCases.compactMap { bucket in
         guard let items = dict[bucket] else { return nil }
         return (key: bucket.rawValue, items: items)
      }
   }

   private var groupedItems: [(key: String, items: [StoreItem])] {
      switch groupingMode {
      case .store: return groupedByStore
      case .expiry: return groupedByExpiry
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
         VStack(spacing: 0) {
            Picker("Gruppierung", selection: $groupingMode) {
               ForEach(GroupingMode.allCases, id: \.self) { mode in
                  Text(mode.rawValue).tag(mode)
               }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            .padding(.vertical, 8)
            itemList
         }
      } else {
         Empty()
      }
   }

   private var itemList: some View {
      List {
         ForEach(groupedItems, id: \.key) { group in
            Section(group.key) {
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
