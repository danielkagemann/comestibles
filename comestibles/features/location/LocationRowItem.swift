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
                    .font(.title2)
                Spacer()

                if count == 0 {
                    Text("Keine Artikel", tableName: "Localizable").font(.caption)
                } else {
                    Text(String(format: String(localized: "%lld Artikel"), count)).font(.caption)
                }
            }

            Group {
                if let data = item.image, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: .infinity, height: 180)
                        .clipped()
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                } else {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray6))
                        .overlay {
                            Text("?")
                                .padding()
                        }
                        .frame(width: .infinity,  height: 180)
                }
            }
        }
        .padding(.vertical, 2)
    }
}
