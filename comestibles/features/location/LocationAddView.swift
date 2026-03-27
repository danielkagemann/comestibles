import CoreLocation
import MapKit
import PhotosUI
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
   @State private var address: String = ""
   @State private var selectedImageData: Data?
   @State private var pickerItem: PhotosPickerItem?
   @State private var showCamera: Bool = false

   @State private var isGeocoding: Bool = false
   @State private var locationError: String?

   @State private var locationManager = SimpleLocationManager()
   @State private var geocodeWorkItem: DispatchWorkItem?

   private var isValid: Bool {
      !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isExisting
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
            Section("Name") {
               TextField("Name des Standorts", text: $name)
                  .textInputAutocapitalization(.words)
               
               if isExisting {
                  Text("Standort bereits vorhanden")
                     .font(.caption2)
                     .foregroundStyle(.red)
               }
               if let data = selectedImageData, let uiImage = UIImage(data: data) {
                  Image(uiImage: uiImage)
                     .resizable()
                     .scaledToFill()
                     .frame(maxWidth: .infinity)
                     .frame(height: 180)
                     .clipped()
                     .listRowInsets(EdgeInsets())
               }
               HStack (spacing: 16){
                  PhotosPicker(selection: $pickerItem, matching: .images) {
                     Image(systemName: "photo.on.rectangle")
                  }
                  .buttonStyle(.borderless)
                  Button {
                     showCamera = true
                  } label: {
                     Image(systemName: "camera")
                  }
                  .buttonStyle(.borderless)
                  
                  if selectedImageData != nil {
                     Spacer()
                     Button(role: .destructive) {
                        selectedImageData = nil
                        pickerItem = nil
                     } label: {
                        Image(systemName: "trash")
                     }
                     .buttonStyle(.borderless)
                  }
               }

            }
            Section("Adresse (optional)") {
               TextField("Adresse", text: $address)
                  .textInputAutocapitalization(.words)
               HStack {
                  Spacer()
                  Button("Aktueller Standort") {
                     requestCurrentLocation()
                  }
               }
            }
         }
         .navigationTitle("Standort")
         .navigationBarTitleDisplayMode(.inline)
         .onChange(of: pickerItem) { _, item in
            Task {
               selectedImageData = try? await item?.loadTransferable(type: Data.self)
            }
         }
         .sheet(isPresented: $showCamera) {
            CameraPickerView { image in
               selectedImageData = image.jpegData(compressionQuality: 0.9)
            }
         }
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

   private func requestCurrentLocation() {
      locationError = nil
      isGeocoding = true
      locationManager.requestOnce { result in
         switch result {
         case let .success(coordinate):
            // Reverse geocode to fill address fields
            let clLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            guard let request = MKReverseGeocodingRequest(location: clLocation) else {
               isGeocoding = false
               locationError = "Reverse Geocoding konnte nicht gestartet werden."
               return
            }
            request.getMapItems { mapItems, error in
               defer { isGeocoding = false }
               if let error = error {
                  locationError = "Reverse Geocoding fehlgeschlagen: \(error.localizedDescription)"
                  return
               }
               guard let mapItem = mapItems?.first else {
                  locationError = "Keine Adressdaten für diese Position gefunden."
                  return
               }

               address = mapItem.address?.fullAddress ?? mapItem.addressRepresentations?.fullAddress(includingRegion: false, singleLine: true) ?? ""
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
      let location = Location(name: trimmed, address: address.isEmpty ? nil : address, image: selectedImageData)
      modelContext.insert(location)
      onSave(location)
      dismiss()
   }
}

private struct CameraPickerView: UIViewControllerRepresentable {
   let onCapture: (UIImage) -> Void
   @Environment(\.dismiss) private var dismiss

   func makeCoordinator() -> Coordinator { Coordinator(self) }

   func makeUIViewController(context: Context) -> UIImagePickerController {
      let picker = UIImagePickerController()
      picker.sourceType = .camera
      picker.delegate = context.coordinator
      return picker
   }

   func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

   class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
      let parent: CameraPickerView
      init(_ parent: CameraPickerView) { self.parent = parent }

      func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
         if let image = info[.originalImage] as? UIImage {
            parent.onCapture(image)
         }
         parent.dismiss()
      }

      func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
         parent.dismiss()
      }
   }
}

#Preview {
   LocationAddView()
}
