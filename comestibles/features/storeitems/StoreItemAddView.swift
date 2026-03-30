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
                Section("Barcode") {
                      TextField("Manuelle Eingabe (optional)", text: $barcode)
                         .keyboardType(.numberPad)
                   
                   HStack {
                      Button("Prüfen") {
                         retrieveProductInformation(barcode)
                      }
                      .disabled(barcode.isEmpty)
                      Spacer()
                      Button("Barcode scannen") {
                         self.showScanner = .visible
                      }
                   }

                    if showScanner == .visible {
                        VStack {
                            CodeScannerView(codeTypes: [.ean8, .ean13, .code39, .code93, .code128],
                                            showViewfinder: true,
                                            completion: handleScan)

                            HStack {
                                Spacer()
                                Button("Scannen abbrechen") {
                                    self.showScanner = .hidden
                                }
                            }
                        }
                        .frame(height: 280)
                    }

                    if showScanner == .retrieve {
                        Text("Suche nach Produktinformationen...")
                    }
                }

               Section("Artikelinformationen") {
                  TextField("Name", text: $name)
                  
                  Stepper("Menge: \(quantity)", value: $quantity, in: 1 ... 999)
                  
               }
               
               Section("Haltbarkeit") {
                    DatePicker("Ablaufdatum", selection: $dueDate, displayedComponents: .date).datePickerStyle(.wheel)
                    TextField("Notizen (optional)", text: $notes)
                    TextField("Geschäfte (optional)", text: $stores)
                }
            }
            .navigationTitle("Hinzufügen")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                   Button(action: {dismiss()}, label: {
                      Image(systemName: "arrow.left")
                   })
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Speichern") { save() }
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
            notes: notes.isEmpty ? nil : notes,
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
