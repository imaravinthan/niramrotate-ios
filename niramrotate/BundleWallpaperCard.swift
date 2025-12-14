//
//  BundleWallpaperCard.swift
//  niramrotate
//
//  Created by aravinthan.selvaraj on 14/12/25.
//

import SwiftUI

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
                Color.gray.opacity(0.3)
            }

            LinearGradient(
                colors: [.clear, .black.opacity(0.6)],
                startPoint: .top,
                endPoint: .bottom
            )

            VStack(alignment: .leading, spacing: 4) {
                Text(bundle.name)
                    .font(.headline)
                Text("\(bundle.imageCount) images")
                    .font(.caption)
                    .opacity(0.8)
            }
            .padding()
        }
        .frame(height: 220) // FULL wallpaper feel
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}
