import CoreLocation
import MapKit
import SwiftData
import SwiftUI

struct LocationAddView: View {
   /// /environments
   @Environment(\.modelContext) private var modelContext
   @Environment(\.dismiss) private var dismiss

   /// queries
   @Query(sort: \Location.name) private var locations: [Location]

   //// input
   var onSave: (Location) -> Void = { _ in }

   /// states
   @State private var name: String = ""
   @State private var street: String = ""
   @State private var postalCode: String = ""
   @State private var city: String = ""

   @State private var region: MKCoordinateRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 52.5200, longitude: 13.4050), span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
   @State private var selectedCoordinate: CLLocationCoordinate2D?

   private let geocoder = CLGeocoder()
   @State private var isGeocoding: Bool = false
   @State private var locationError: String?

   @State private var locationManager = SimpleLocationManager()
   @State private var geocodeWorkItem: DispatchWorkItem?

   private var isValid: Bool {
      !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isExisting
   }

   private var isAddress: Bool {
      !street.isEmpty && (!postalCode.isEmpty || !city.isEmpty)
   }

   private var isExisting: Bool {
      if locations.isEmpty { return false }
      return locations.first {
         $0.name.trimmingCharacters(in: .whitespacesAndNewlines) == name.trimmingCharacters(in: .whitespacesAndNewlines)
      } != nil
   }

   var body: some View {
      NavigationStack {
         Form {
            Section("Standort") {
               TextField("Name des Standorts", text: $name)
                  .textInputAutocapitalization(.words)
               
               if isExisting {
                  Text("Standort bereits vorhanden")
                     .font(.caption2)
                     .foregroundStyle(.red)
               }
            }
            Section("Adresse") {
               TextField("Straße und Hausnummer", text: $street)
                  .onChange(of: street) { _ in scheduleSilentGeocode() }
               TextField("PLZ", text: $postalCode)
                  .keyboardType(.numbersAndPunctuation)
                  .onChange(of: postalCode) { _ in scheduleSilentGeocode() }
               TextField("Stadt", text: $city)
                  .textInputAutocapitalization(.words)
                  .onChange(of: city) { _ in scheduleSilentGeocode() }
               HStack {
                  Spacer()
                  Button("Aktueller Standort") {
                     requestCurrentLocation()
                  }
               }
            }
            Section("Karte") {
               Map(coordinateRegion: $region, interactionModes: [.zoom, .pan], annotationItems: selectedCoordinate.map { [MapPinItem(coordinate: $0)] } ?? []) { item in
                  MapMarker(coordinate: item.coordinate, tint: .accentColor)
               }
               .frame(height: 180)
               .clipShape(RoundedRectangle(cornerRadius: 12))
               .overlay(
                  RoundedRectangle(cornerRadius: 12).stroke(.quaternary)
               )

               if let locationError {
                  Text(locationError)
                     .font(.footnote)
                     .foregroundStyle(.red)
               }
            }
            Section {
               Button(action: geocodeAddress) {
                  Text("Adresse suchen")
               }
               .disabled(!isAddress)
            }
         }
         .navigationTitle("Standort hinzufügen")
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

   private func geocodeAddress() {
      let trimmedStreet = street.trimmingCharacters(in: .whitespacesAndNewlines)
      let trimmedCity = city.trimmingCharacters(in: .whitespacesAndNewlines)
      let trimmedPostal = postalCode.trimmingCharacters(in: .whitespacesAndNewlines)
      var parts: [String] = []
      if !trimmedStreet.isEmpty { parts.append(trimmedStreet) }
      if !trimmedPostal.isEmpty { parts.append(trimmedPostal) }
      if !trimmedCity.isEmpty { parts.append(trimmedCity) }
      let query = parts.joined(separator: ", ")
      guard !query.isEmpty else {
         locationError = "Bitte geben Sie eine Adresse ein."
         return
      }
      isGeocoding = true
      locationError = nil
      geocoder.geocodeAddressString(query) { placemarks, error in
         isGeocoding = false
         if let error = error {
            locationError = "Geocoding fehlgeschlagen: \(error.localizedDescription)"
            return
         }
         guard let coordinate = placemarks?.first?.location?.coordinate else {
            locationError = "Keine Position für diese Adresse gefunden."
            return
         }
         selectedCoordinate = coordinate
         withAnimation {
            region.center = coordinate
         }
      }
   }

   private func silentlyGeocodeCurrentAddress() {
      let trimmedStreet = street.trimmingCharacters(in: .whitespacesAndNewlines)
      let trimmedCity = city.trimmingCharacters(in: .whitespacesAndNewlines)
      let trimmedPostal = postalCode.trimmingCharacters(in: .whitespacesAndNewlines)

      var parts: [String] = []
      if !trimmedStreet.isEmpty { parts.append(trimmedStreet) }
      if !trimmedPostal.isEmpty { parts.append(trimmedPostal) }
      if !trimmedCity.isEmpty { parts.append(trimmedCity) }

      let query = parts.joined(separator: ", ")
      guard !query.isEmpty else { return }

      geocoder.geocodeAddressString(query) { placemarks, _ in
         guard let coordinate = placemarks?.first?.location?.coordinate else { return }
         selectedCoordinate = coordinate
         withAnimation {
            region.center = coordinate
         }
      }
   }

   private func scheduleSilentGeocode() {
      guard isAddress else { return }
      geocodeWorkItem?.cancel()
      let workItem = DispatchWorkItem { [weak geocoder] in
         silentlyGeocodeCurrentAddress()
      }
      geocodeWorkItem = workItem
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.6, execute: workItem)
   }

   private func requestCurrentLocation() {
      locationError = nil
      isGeocoding = true
      locationManager.requestOnce { result in
         switch result {
         case let .success(coordinate):
            selectedCoordinate = coordinate
            withAnimation {
               region.center = coordinate
            }

            // Reverse geocode to fill address fields
            let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            geocoder.reverseGeocodeLocation(location) { placemarks, error in
               defer { isGeocoding = false }
               if let error = error {
                  locationError = "Reverse Geocoding fehlgeschlagen: \(error.localizedDescription)"
                  return
               }
               guard let placemark = placemarks?.first else {
                  locationError = "Keine Adressdaten für diese Position gefunden."
                  return
               }

               // Compose street from thoroughfare and subThoroughfare if available
               let streetName = placemark.thoroughfare ?? ""
               let streetNumber = placemark.subThoroughfare ?? ""
               let composedStreet: String
               if streetName.isEmpty {
                  composedStreet = streetNumber
               } else if streetNumber.isEmpty {
                  composedStreet = streetName
               } else {
                  composedStreet = "\(streetName) \(streetNumber)"
               }

               street = composedStreet
               postalCode = placemark.postalCode ?? ""
               city = placemark.locality ?? placemark.subLocality ?? placemark.administrativeArea ?? ""
            }

         case let .failure(error):
            isGeocoding = false
            locationError = error.localizedDescription
         }
      }
   }

   private func save() {
      let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
      guard !trimmed.isEmpty else { return }
      let location = Location(name: trimmed, street: street.isEmpty ? nil : street, postalCode: postalCode.isEmpty ? nil : postalCode, city: city.isEmpty ? nil : city, latitude: selectedCoordinate?.latitude, longitude: selectedCoordinate?.longitude)
      modelContext.insert(location)
      onSave(location)
      dismiss()
   }
}

private struct MapPinItem: Identifiable {
   let id = UUID()
   let coordinate: CLLocationCoordinate2D
}

#Preview {
   LocationAddView()
}
