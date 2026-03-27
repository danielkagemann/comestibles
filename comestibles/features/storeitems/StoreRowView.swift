//
//  StoreRowView.swift
//  comestibles
//
//  Created by Daniel Kagemann on 22.03.26.
//

import SwiftUI
import Kingfisher

struct StoreRowView: View {
   /// input
   let item: StoreItem

   var body: some View {
      VStack {
         HStack {
            KFImage(URL(string: item.image ?? ""))
               .placeholder {
                  RoundedRectangle(cornerRadius: 12)
                     .fill(Color(.systemGray6))
                     .overlay {
                        Text("?")
                           .padding()
                     }
               }
               .resizable()
               .scaledToFill()
               .frame(width: 58, height: 58)
               .clipped()
               .clipShape(RoundedRectangle(cornerRadius: 12))

            
            VStack (alignment: .leading, spacing: 4){
               HStack {
                  Text(item.name)
                     .font(.headline)
                  Spacer()
                  ExpiryBadge(item: item)
               }
               Group {
                  Label(item.location.name, systemImage: "mappin.and.ellipse.circle")
                  Label("\(item.quantity)", systemImage: "numbers.rectangle")
               }
               .font(.caption)
               .foregroundStyle(.secondary)
            }
         }
      }
      .padding(.vertical, 2)
   }
}

private struct ExpiryBadge: View {
   /// input
   let item: StoreItem
   
   var body: some View {
      let days = item.daysUntilExpiry
      let color: Color = item.isExpired ? .red : days <= 3 ? .orange : .green
      let label = item.isExpired ? "Abgelaufen" : days == 0 ? "heute" : days.smartDays()
      
      Text(label)
         .font(.caption2.bold())
         .padding(.horizontal, 8)
         .padding(.vertical, 3)
         .background(color.opacity(0.15))
         .foregroundStyle(color)
         .clipShape(Capsule())
   }
}

#Preview {
   let item = StoreItem(name: "Test", location: .init(name: "zuhause"))
   item.quantity = 5
   item.barcode = "12345"
   item.image = "https://images.openfoodfacts.org/images/products/848/000/022/3111/front_es.90.400.jpg"
   return StoreRowView(item: item)
}

