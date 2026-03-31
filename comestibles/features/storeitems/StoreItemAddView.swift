//
//  StoreItemAddView.swift
//  comestibles
//
//  Created by Daniel Kagemann on 22.03.26.
//

import AVFoundation
import CodeScanner
import SwiftData
import SwiftUI

enum ScannerType {
    case hidden
    case visible
    case retrieve
}

struct StoreItemAddView: View {
    /// input
    var location: Location

    /// environment
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    /// queries
    @Query(sort: \Location.name) private var locations: [Location]

    /// states
    @State private var name = ""
    @State private var barcode = ""
    @State private var dueDate = Date.now
    @State private var quantity = 1
    @State private var notes = ""
    @State private var image = ""
    @State private var stores = ""
    @State private var showScanner: ScannerType = .hidden

    private struct QuickDuration {
        let label: String
        let component: Calendar.Component
        let value: Int
    }

    private let quickDurations: [QuickDuration] = [
        QuickDuration(label: "1T", component: .day, value: 1),
        QuickDuration(label: "1W", component: .weekOfYear, value: 1),
        QuickDuration(label: "1M", component: .month, value: 1),
        QuickDuration(label: "6M", component: .month, value: 6),
        QuickDuration(label: "1J", component: .year, value: 1),
    ]

    private var isValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
    }

    func retrieveProductInformation(_ code: String) {
        showScanner = .retrieve

        Grocery.fromCode(code) { food in
            self.barcode = food!.code
            self.name = (food?.product.product_name ?? food?.product.product_name_en ?? "Unbekannt")
            self.image = food?.product.image_front_url ?? ""
            self.stores = food?.product.stores ?? ""
            showScanner = .hidden
        }
    }

    func handleScan(result: Result<ScanResult, ScanError>) {
        switch result {
        case let .success(result):
            let code = result.string.components(separatedBy: "\n").first ?? ""
            if code.isEmpty {
                return
            }
            retrieveProductInformation(code)
        case let .failure(error):
            print("Scanning failed: \(error.localizedDescription)")
            showScanner = .hidden
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(String(localized: "Barcode")) {
                    TextField(String(localized: "Manuelle Eingabe (optional)"), text: $barcode)
                        .keyboardType(.numberPad)

                    HStack {
                        Button(String(localized: "Prüfen")) {
                            retrieveProductInformation(barcode)
                        }
                        .disabled(barcode.isEmpty)
                        Spacer()
                        Button(String(localized: "Barcode scannen")) {
                            self.showScanner = .visible
                        }
                    }
                   
                   Text("Daten werden von Open Food Facts bereitgestellt.").font(.caption)

                    if showScanner == .visible {
                        VStack {
                            CodeScannerView(codeTypes: [.ean8, .ean13, .code39, .code93, .code128],
                                            showViewfinder: true,
                                            completion: handleScan)

                            HStack {
                                Spacer()
                                Button(String(localized: "Scannen abbrechen")) {
                                    self.showScanner = .hidden
                                }
                            }
                        }
                        .frame(height: 280)
                    }

                    if showScanner == .retrieve {
                        Text("Suche nach Produktinformationen...", tableName: "Localizable")
                    }
                }

                Section(String(localized: "Artikelinformationen")) {
                    TextField(String(localized: "Name"), text: $name)
                    Stepper(String(format: String(localized: "Menge: %lld"), quantity), value: $quantity, in: 1 ... 999)
                }

                Section(String(localized: "Haltbarkeit")) {
                    // quick preset buttons for timespan
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(quickDurations, id: \.label) { item in
                                Button(item.label) {
                                    dueDate = Calendar.current.date(byAdding: item.component, value: item.value, to: dueDate) ?? .now
                                }
                                .buttonStyle(.bordered)
                                .buttonBorderShape(.capsule)
                                .tint(.accentColor)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))

                    DatePicker(String(localized: "Ablaufdatum"), selection: $dueDate, displayedComponents: .date)
                        .datePickerStyle(.compact)

                    TextField(String(localized: "Notizen (optional)"), text: $notes)
                    TextField(String(localized: "Geschäfte (optional)"), text: $stores)
                }
            }
            .navigationTitle(String(localized: "Hinzufügen"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: { dismiss() }, label: {
                        Image(systemName: "arrow.left")
                    })
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(String(localized: "Speichern")) { save() }
                        .disabled(!isValid)
                }
            }
        }
    }

    private func save() {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)

        let item = StoreItem(
            name: trimmedName,
            location: location,
            barcode: barcode.isEmpty ? nil : barcode,
            dueDate: dueDate,
            quantity: quantity,
            stores: stores,
            image: image
        )
        modelContext.insert(item)

        dismiss()
    }
}

#Preview {
    let loc = Location(name: "Store 1")
    StoreItemAddView(location: loc)
}
