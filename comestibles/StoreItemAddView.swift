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
   /// appstorage
   @AppStorage("lastlocation") private var lastLocation: String = ""
   
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
   @State private var selectedLocation: Location?
   @State private var showScanner: ScannerType = .hidden
   @State private var showingAddLocation: Bool = false

   private var isValid: Bool {
      !name.trimmingCharacters(in: .whitespaces).isEmpty && selectedLocation != nil
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
               Button("Barcode scannen") {
                  self.showScanner = .visible
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

            Section("Standort") {
               if locations.isEmpty {
                  Text("Kein Standort gefunden.")
                     .foregroundStyle(.secondary)
                     .font(.callout)
               } else {
                  Picker("Location", selection: $selectedLocation) {
                     Text("Auswählen...").tag(Optional<Location>(nil))
                     ForEach(locations) { location in
                        Text(location.name).tag(Optional(location))
                     }
                  }.onChange(of: $selectedLocation, {prev, value in
                     lastLocation = selectedLocation.name
                  })
               }
               Button("Standort hinzufügen") {
                  showingAddLocation = true
               }
            }

            Section("Artikelinformationen") {
               TextField("Name", text: $name)

               Stepper("Menge: \(quantity)", value: $quantity, in: 1 ... 999)

               HStack {
                  TextField("Barcode (optional)", text: $barcode)
                     .keyboardType(.numberPad)
                  Button(action: {
                     retrieveProductInformation(barcode)
                  }, label: {
                     Text("Prüfen").font(.caption)
                  }).disabled(barcode.isEmpty)
               }

               DatePicker("Ablaufdatum", selection: $dueDate, displayedComponents: .date).datePickerStyle(.wheel)
               TextField("Notizen (optional)", text: $notes)
               TextField("Geschäfte (optional)", text: $stores)
            }
         }
         .sheet(isPresented: $showingAddLocation) {
            LocationAddView { newLocation in
               // Select the newly created location and close the sheet
               self.selectedLocation = newLocation
               self.showingAddLocation = false
            }
         }
         .navigationTitle("Hinzufügen")
         .navigationBarTitleDisplayMode(.automatic)
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
      guard let location = selectedLocation else { return }
      let trimmedName = name.trimmingCharacters(in: .whitespaces)

      let item = StoreItem(
         name: trimmedName,
         location: location,
         barcode: barcode.isEmpty ? nil : barcode,
         dueDate: dueDate,
         quantity: quantity,
         notes: notes.isEmpty ? nil : notes,
         stores: stores
      )
      modelContext.insert(item)

      dismiss()
   }
}

#Preview {
   StoreItemAddView()
}
