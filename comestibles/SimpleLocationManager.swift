//
//  SimpleLocationManager.swift
//  comestibles
//
//  Created by Daniel Kagemann on 22.03.26.
//

import CoreLocation

class SimpleLocationManager: NSObject, CLLocationManagerDelegate {
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
