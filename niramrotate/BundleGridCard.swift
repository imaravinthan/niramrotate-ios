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
        VStack(alignment: .leading, spacing: 8) {

            ZStack {
                if let image = ImageBundleStore.shared.loadRandomThumbnail(for: bundle) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                } else {
                    Color.gray.opacity(0.25)
                }
            }
            .frame(height: 130)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .clipped()

            Text(bundle.name)
                .font(.headline)

            Text("\(bundle.imageCount) images")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

