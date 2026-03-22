import CoreLocation
import MapKit
import SwiftData
import SwiftUI

struct LocationAddView: View {
   @Environment(\.modelContext) private var modelContext
   @Environment(\.dismiss) private var dismiss

   var onSave: (Location) -> Void = { _ in }

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

   private var isValid: Bool {
      !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
   }

   private var isAddress: Bool {
      !street.isEmpty && (!postalCode.isEmpty || !city.isEmpty)
   }

   var body: some View {
      NavigationStack {
         Form {
            Section("Standort") {
               TextField("Name des Standorts", text: $name)
                  .textInputAutocapitalization(.words)
            }
            Section("Adresse") {
               TextField("Straße und Hausnummer", text: $street)
               TextField("PLZ", text: $postalCode)
                  .keyboardType(.numbersAndPunctuation)
               TextField("Stadt", text: $city)
                  .textInputAutocapitalization(.words)
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

               if let selectedCoordinate {
                  HStack {
                     Image(systemName: "mappin.circle")
                     Text(String(format: "%.5f, %.5f", selectedCoordinate.latitude, selectedCoordinate.longitude))
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                  }
               } else {
                  Text("Keine Koordinate ausgewählt")
                     .font(.footnote)
                     .foregroundStyle(.secondary)
               }

               if let locationError {
                  Text(locationError)
                     .font(.footnote)
                     .foregroundStyle(.red)
               }

               HStack {
                  Button(action: geocodeAddress) {
                     if isGeocoding { ProgressView() } else { Text("Adresse suchen") }
                  }
                  .disabled(isAddress)
                  Spacer()
                  Button("Aktueller Standort") {
                     requestCurrentLocation()
                  }
               }
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

   private func requestCurrentLocation() {
      locationError = nil
      locationManager.requestOnce { result in
         switch result {
         case let .success(coordinate):
            selectedCoordinate = coordinate
            withAnimation {
               region.center = coordinate
            }
         case let .failure(error):
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

private final class SimpleLocationManager: NSObject, CLLocationManagerDelegate {
   private let manager = CLLocationManager()
   private var completion: ((Result<CLLocationCoordinate2D, Error>) -> Void)?

   override init() {
      super.init()
      manager.delegate = self
   }

   func requestOnce(completion: @escaping (Result<CLLocationCoordinate2D, Error>) -> Void) {
      self.completion = completion
      switch manager.authorizationStatus {
      case .notDetermined:
         manager.requestWhenInUseAuthorization()
      case .denied, .restricted:
         completion(.failure(NSError(domain: "Location", code: 1, userInfo: [NSLocalizedDescriptionKey: "Ortungsdienste deaktiviert oder verweigert."])))
      case .authorizedWhenInUse, .authorizedAlways:
         manager.requestLocation()
      @unknown default:
         manager.requestWhenInUseAuthorization()
      }
   }

   func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
      if manager.authorizationStatus == .authorizedWhenInUse || manager.authorizationStatus == .authorizedAlways {
         manager.requestLocation()
      }
   }

   func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
      if let coordinate = locations.first?.coordinate {
         completion?(.success(coordinate))
      } else {
         completion?(.failure(NSError(domain: "Location", code: 2, userInfo: [NSLocalizedDescriptionKey: "Keine Position erhalten."])))
      }
      completion = nil
   }

   func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
      completion?(.failure(error))
      completion = nil
   }
}

#Preview {
   LocationAddView()
}
