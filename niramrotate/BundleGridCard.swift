//
//  BundleGridCard.swift
//  niramrotate
//
//  Created by aravinthan.selvaraj on 14/12/25.
//

import SwiftUI

struct BundleGridCard: View {

    let bundle: ImageBundle

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {

            ZStack {
                if let image = ImageBundleStore.shared.loadRandomDecryptedImage(forID: bundle.id){
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                } else {
                    Color.black.opacity(0.25)
                }
            }
            .frame(height: 220) // FULL WALLPAPER FEEL
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .clipped()

            Text(bundle.name)
                .font(.headline)

            Text("\(bundle.imageCount) images")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}
