//
//  AddItemView.swift
//  comestibles
//
//  Created by Daniel Kagemann on 22.03.26.
//

import AVFoundation
import CodeScanner
import SwiftData
import SwiftUI

struct AddItemView: View {
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
   @State private var selectedLocation: Location?
   @State private var showScanner: Bool = false
   @State private var showingAddLocation: Bool = false

   private var isValid: Bool {
      !name.trimmingCharacters(in: .whitespaces).isEmpty && selectedLocation != nil
   }

   /**
    handle scanning process
    */
   func handleScan(result: Result<ScanResult, ScanError>) {
      switch result {
      case let .success(result):
         let code = result.string.components(separatedBy: "\n").first ?? ""
         if code.isEmpty {
            return
         }

         Grocery.fromCode(code) { food in
            self.barcode = food!.code
            self.name = (food?.product.product_name ?? "Unbekannt")
            self.image = food!.product.image_front_url ?? ""
            self.showScanner = false
         }
      case let .failure(error):
         print("Scanning failed: \(error.localizedDescription)")
         showScanner = false
      }
   }

   var body: some View {
      NavigationStack {
         Form {
            Section("Barcode") {
               Button("Barcode scannen") {
                  self.showScanner = true
               }

               if showScanner{
                  CodeScannerView(codeTypes: [.ean8, .ean13, .code39, .code93, .code128],
                                  showViewfinder: true,
                                  completion: handleScan)
               }
            }

            Section("Details") {
               TextField("Name", text: $name)

               Stepper("Menge: \(quantity)", value: $quantity, in: 1 ... 999)

               TextField("Barcode (optional)", text: $barcode)
                  .keyboardType(.numberPad)
               DatePicker("Ablaufdatum", selection: $dueDate, displayedComponents: .date)

               TextField("Notes (optional)", text: $notes)
            }

            Section("Standort") {
               if locations.isEmpty {
                  Text("Kein Standort gefunden.")
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
               Button("Standort hinzufügen") {
                  showingAddLocation = true
               }
            }
         }
         .sheet(isPresented: $showingAddLocation) {
            LocationAddView { newLocation in
               // Select the newly created location and close the sheet
               self.selectedLocation = newLocation
               self.showingAddLocation = false
            }
         }
      }
      .navigationTitle("Hinzufügen")
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

   private func save() {
      guard let location = selectedLocation else { return }
      let trimmedName = name.trimmingCharacters(in: .whitespaces)

      let item = StoreItem(
         name: trimmedName,
         location: location,
         barcode: barcode.isEmpty ? nil : barcode,
         dueDate: dueDate,
         quantity: quantity,
         notes: notes.isEmpty ? nil : notes
      )
      modelContext.insert(item)

      dismiss()
   }
}

