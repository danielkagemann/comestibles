import SwiftUI
import SwiftData

struct ItemListView: View {
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \GroceryItem.name) private var groceryItems: [GroceryItem]
    @Query(sort: \StoreItem.name) private var storeItems: [StoreItem]

    @State private var showAddSheet = false
    @State private var selectedTab: ItemTab = .grocery

    enum ItemTab: String, CaseIterable {
        case grocery = "Food"
        case store = "Items"
    }

    private var hasItems: Bool {
        selectedTab == .grocery ? !groceryItems.isEmpty : !storeItems.isEmpty
    }

    var body: some View {
        NavigationStack {
            Group {
                if hasItems {
                    List {
                        if selectedTab == .grocery {
                            ForEach(groceryItems) { item in
                                GroceryRowView(item: item)
                            }
                            .onDelete(perform: deleteGroceryItems)
                        } else {
                            ForEach(storeItems) { item in
                                StoreRowView(item: item)
                            }
                            .onDelete(perform: deleteStoreItems)
                        }
                    }
                } else {
                    EmptyStateView(tab: selectedTab)
                }
            }
            .navigationTitle("Inventory")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showAddSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton()
                }
            }
            .safeAreaInset(edge: .bottom) {
                Picker("Type", selection: $selectedTab) {
                    ForEach(ItemTab.allCases, id: \.self) { tab in
                        Text(tab.rawValue).tag(tab)
                    }
                }
                .pickerStyle(.segmented)
                .padding()
                .background(.ultraThinMaterial)
            }
            .sheet(isPresented: $showAddSheet) {
                AddItemView(preselectedTab: selectedTab)
            }
        }
    }

    private func deleteGroceryItems(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(groceryItems[index])
        }
    }

    private func deleteStoreItems(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(storeItems[index])
        }
    }
}