//
//  BundleWallpaperCard.swift
//  niramrotate
//
//  Created by aravinthan.selvaraj on 14/12/25.
//

import SwiftUI
import UIKit

struct BundleWallpaperCard: View {

    let bundle: ImageBundle
    let image: UIImage?

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                Color.gray.opacity(0.25)
            }

            LinearGradient(
                colors: [.clear, .black.opacity(0.6)],
                startPoint: .top,
                endPoint: .bottom
            )

            VStack(alignment: .leading, spacing: 6) {
                Image(uiImage: image!)
                    .resizable()
                    .scaledToFill()

                Text(bundle.name)
                    .font(.headline)
                    .padding(.horizontal, 8)
            }
            .foregroundColor(.white)
            .padding()
        }
        .frame(height: 220)
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
}
