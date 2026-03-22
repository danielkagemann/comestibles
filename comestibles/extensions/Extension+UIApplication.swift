//
//  Extension+View.swift
//  laiba
//
//  Created by Daniel Kagemann on 17.02.23.
//

import Foundation
import SwiftUI

extension UIApplication {
   static var build: String {
      return Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as? String ?? "?"
   }
   
   static var version: String {
      return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "?"
   }
   
   func currentUIWindow() -> UIWindow? {
      let connectedScenes = UIApplication.shared.connectedScenes
         .filter { $0.activationState == .foregroundActive }
         .compactMap { $0 as? UIWindowScene }
      
      let window = connectedScenes.first?
         .windows
         .first { $0.isKeyWindow }
      return window
   }
}
