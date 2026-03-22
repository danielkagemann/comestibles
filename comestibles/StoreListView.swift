//
//  StoreListView.swift
//  comestibles
//
//  Created by Daniel Kagemann on 22.03.26.
//


import SwiftUI
import SwiftData

struct StoreListView: View {
   /// environment
    @Environment(\.modelContext) private var modelContext

   /// queries
    @Query(sort: \StoreItem.name) private var storeItems: [StoreItem]

   /// states
    @State private var showAddSheet = false

    private var hasItems: Bool {
       !storeItems.isEmpty
    }

    var body: some View {
        NavigationStack {
            Group {
                if hasItems {
                    List {
                      ForEach(storeItems) { item in
                          StoreRowView(item: item)
                      }
                      .onDelete(perform: deleteStoreItems)
                    }
                } else {
                    EmptyStateView()
                }
            }
            .navigationTitle("Lebensmittel")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showAddSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddSheet) {
               StoreItemAddView()
            }
        }
    }

    private func deleteStoreItems(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(storeItems[index])
        }
    }
}
