//
//  LocationRowItem.swift
//  comestibles
//
//  Created by Daniel Kagemann on 26.03.26.
//

import SwiftUI

struct LocationRowItem: View {
   /// input
   var item: Location
   var count: Int

   var body: some View {
      VStack(alignment: .leading, spacing: 2) {
         HStack {
            Text(item.name)
               .font(.headline)
            Spacer()

            if count == 0 {
               Text("Keine Artikel").font(.caption)
            } else {
               Text("\(count) Artikel").font(.caption)
            }
         }

         Group {
            if let data = item.image, let uiImage = UIImage(data: data) {
               Image(uiImage: uiImage)
                  .resizable()
                  .scaledToFill()
            } else {
               RoundedRectangle(cornerRadius: 12)
                  .fill(Color(.systemGray6))
                  .overlay {
                     Text("?")
                        .padding()
                  }
            }
         }
         .frame(width: .infinity, height: 150)
         .clipped()
      }
      .padding(.vertical, 2)
   }
}
