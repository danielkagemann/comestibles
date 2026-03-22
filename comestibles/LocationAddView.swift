import SwiftUI
import SwiftData

struct LocationAddView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    var onSave: (Location) -> Void = { _ in }

    @State private var name: String = ""

    private var isValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Standort") {
                    TextField("Name des Standorts", text: $name)
                        .textInputAutocapitalization(.words)
                }
            }
            .navigationTitle("Standort hinzufügen")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Speichern") { save() }
                        .disabled(!isValid)
                }
            }
        }
    }

    private func save() {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let location = Location(name: trimmed)
        modelContext.insert(location)
        onSave(location)
        dismiss()
    }
}

#Preview {
    LocationAddView()
}
