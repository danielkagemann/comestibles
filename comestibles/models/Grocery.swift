//
//  Grocery.swift
//  comestibles
//
//  Created by Daniel Kagemann on 22.03.26.
//

import Foundation


struct GroceryItem: Decodable {
   var code: String
   var product: Product
   
   struct Product: Decodable {
      var product_name: String?
      var product_name_en: String?
      var stores: String?
      var image_front_url: String?
      var product_quantity: String?
      var product_quantity_unit: String?
   }
}


class Grocery {
   static func fromCode (_ code: String, action: @escaping(_ item: GroceryItem?) -> Void) -> Void {
      if code.isEmpty {
         return
      }
      
      let url = URL(string: "https://world.openfoodfacts.org/api/v2/product/\(code)?fields=code,product_name,product_name_en,product_quantity,product_quantity_unit,stores,image_front_small_url")
      let request = URLRequest(url: url!)
      URLSession.shared.dataTask(with: request) { data, response, error in
         if let data = data {
            do {
               let decodedResponse = try JSONDecoder().decode(GroceryItem.self, from: data)
               
               // we have good data – go back to the main thread
               DispatchQueue.main.async {
                  action(decodedResponse)
                  return
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
