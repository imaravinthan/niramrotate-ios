//
//  BundleLibraryRow.swift
//  niramrotate
//
//  Created by aravinthan.selvaraj on 15/12/25.
//

import SwiftUI

struct BundleLibraryRow: View {
    let bundle: ImageBundle

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                if let image = ImageBundleStore.shared.loadRandomDecryptedImage(forID: bundle.id) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                } else {
                    Color.gray.opacity(0.3)
                }
            }
            .frame(width: 80, height: 120)
            .clipShape(RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 6) {
                Text(bundle.name)
                    .font(.headline)

                Text("\(bundle.imageCount) wallpapers")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text(bundle.createdAt, style: .date)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
    }
}
