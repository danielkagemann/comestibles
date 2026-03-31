//
//  Grocery.swift
//  comestibles
//
//  Created by Daniel Kagemann on 22.03.26.
//

import Foundation

struct GroceryItem: Codable {
   var code: String
   var product: Product

   struct Product: Codable {
      var product_name: String?
      var product_name_en: String?
      var stores: String?
      var image_front_url: String?
      var product_quantity: String?
      var product_quantity_unit: String?
   }
}

class Grocery {
   /// Cache-Eintrag mit Zeitstempel für TTL-Prüfung
   private struct CachedEntry: Codable {
      let item: GroceryItem
      let cachedAt: Date
   }

   private static let cacheKey = "grocery_barcode_cache"
   private static let cacheTTL: TimeInterval = 60 * 60 * 24 * 30 // 30 Tage

   /// In-memory Spiegel des persistierten Cache
   private static var cache: [String: CachedEntry] = {
      guard let data = UserDefaults.standard.data(forKey: cacheKey),
            let decoded = try? JSONDecoder().decode([String: CachedEntry].self, from: data)
      else { return [:] }
      return decoded
   }()

   private static func persist() {
      if let data = try? JSONEncoder().encode(cache) {
         UserDefaults.standard.set(data, forKey: cacheKey)
      }
   }

   private static func validCached(for code: String) -> GroceryItem? {
      guard let entry = cache[code] else { return nil }
      let age = Date.now.timeIntervalSince(entry.cachedAt)
      guard age < cacheTTL else {
         // Abgelaufen: Eintrag entfernen
         cache.removeValue(forKey: code)
         persist()
         return nil
      }
      return entry.item
   }

   static func fromCode(_ code: String, action: @escaping (_ item: GroceryItem?) -> Void) {
      guard !code.isEmpty else { return }

      // Cache-Treffer: sofort zurückgeben, kein Netzwerkabruf
      if let cached = validCached(for: code) {
         print("Cache hit for barcode \(code)")
         action(cached)
         return
      }

      let url = URL(string: "https://world.openfoodfacts.org/api/v2/product/\(code)?fields=code,product_name,product_name_en,product_quantity,product_quantity_unit,stores,image_front_small_url")
      let request = URLRequest(url: url!)
      URLSession.shared.dataTask(with: request) { data, response, error in
         if let data = data {
            do {
               let decodedResponse = try JSONDecoder().decode(GroceryItem.self, from: data)

               // Persistiert im Cache speichern
               cache[code] = CachedEntry(item: decodedResponse, cachedAt: .now)
               persist()

               DispatchQueue.main.async {
                  action(decodedResponse)
               }
            } catch DecodingError.keyNotFound(let key, let context) {
               print("could not find key \(key) in JSON: \(context.debugDescription)")
            } catch DecodingError.valueNotFound(let type, let context) {
               print("could not find type \(type) in JSON: \(context.debugDescription)")
            } catch DecodingError.typeMismatch(let type, let context) {
               print("type mismatch for type \(type) in JSON: \(context.debugDescription) \(context.codingPath)")
            } catch DecodingError.dataCorrupted(let context) {
               print("data found to be corrupted in JSON: \(context.debugDescription)")
            } catch let error as NSError {
               NSLog("Error in read(from:ofType:) domain= \(error.domain), description= \(error.localizedDescription)")
            }
         }
      }.resume()
   }
}
