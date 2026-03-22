import SwiftUI
import SwiftData

struct AddItemView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @Query(sort: \Location.name) private var locations: [Location]

    let preselectedTab: ItemListView.ItemTab

    @State private var selectedTab: ItemListView.ItemTab
    @State private var name = ""
    @State private var barcode = ""
    @State private var dueDate = Date.now
    @State private var quantity = 1
    @State private var category = ""
    @State private var notes = ""
    @State private var selectedLocation: Location?

    init(preselectedTab: ItemListView.ItemTab) {
        self.preselectedTab = preselectedTab
        _selectedTab = State(initialValue: preselectedTab)
    }

    private var isValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty && selectedLocation != nil
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Type") {
                    Picker("Type", selection: $selectedTab) {
                        ForEach(ItemListView.ItemTab.allCases, id: \.self) { tab in
                            Text(tab.rawValue).tag(tab)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section("Details") {
                    TextField("Name", text: $name)

                    Stepper("Quantity: \(quantity)", value: $quantity, in: 1...999)

                    if selectedTab == .grocery {
                        TextField("Barcode (optional)", text: $barcode)
                            .keyboardType(.numberPad)
                        DatePicker("Due Date", selection: $dueDate, displayedComponents: .date)
                    } else {
                        TextField("Category (optional)", text: $category)
                    }

                    TextField("Notes (optional)", text: $notes)
                }

                Section("Location") {
                    if locations.isEmpty {
                        Text("No locations available. Please add a location first.")
                            .foregroundStyle(.secondary)
                            .font(.callout)
                    } else {
                        Picker("Location", selection: $selectedLocation) {
                            Text("Select…").tag(Optional<Location>(nil))
                            ForEach(locations) { location in
                                Text(location.name).tag(Optional(location))
                            }
                        }
                    }
                }
            }
            .navigationTitle("Add Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") { save() }
                        .disabled(!isValid)
                }
            }
        }
    }

    private func save() {
        guard let location = selectedLocation else { return }
        let trimmedName = name.trimmingCharacters(in: .whitespaces)

        if selectedTab == .grocery {
            let item = GroceryItem(
                name: trimmedName,
                location: location,
                barcode: barcode.isEmpty ? nil : barcode,
                dueDate: dueDate,
                quantity: quantity,
                notes: notes.isEmpty ? nil : notes
            )
            modelContext.insert(item)
        } else {
            let item = StoreItem(
                name: trimmedName,
                location: location,
                category: category.isEmpty ? nil : category,
                quantity: quantity,
                notes: notes.isEmpty ? nil : notes
            )
            modelContext.insert(item)
        }
        dismiss()
    }
}