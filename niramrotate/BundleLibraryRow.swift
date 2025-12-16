//
//  BundleLibraryRow.swift
//  niramrotate
//
//  Created by aravinthan.selvaraj on 15/12/25.
//

//import SwiftUI
//
//struct BundleLibraryRow: View {
//    let bundle: ImageBundle
//
//    var body: some View {
//        HStack(spacing: 12) {
//            ZStack {
//                if let image = ImageBundleStore.shared.loadRandomDecryptedImage(forID: bundle.id) {
//                    Image(uiImage: image)
//                        .resizable()
//                        .scaledToFill()
//                } else {
//                    Color.gray.opacity(0.3)
//                }
//            }
//            .frame(width: 80, height: 120)
//            .clipShape(RoundedRectangle(cornerRadius: 12))
//
//            VStack(alignment: .leading, spacing: 6) {
//                Text(bundle.name)
//                    .font(.headline)
//
//                Text("\(bundle.imageCount) wallpapers")
//                    .font(.caption)
//                    .foregroundStyle(.secondary)
//
//                Text(bundle.createdAt, style: .date)
//                    .font(.caption2)
//                    .foregroundStyle(.secondary)
//            }
//
//            Spacer()
//        }
//    }
//}

import SwiftUI

struct BundleLibraryRow: View {
    let bundle: ImageBundle

    @EnvironmentObject private var settings: AppSettings

    var body: some View {
        HStack(spacing: 12) {

            if let image = ImageBundleStore.shared
                .loadRandomDecryptedImage(forID: bundle.id) {

                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .blur(
                        radius: bundle.isNSFW && settings.blurNSFWBundleEnabled
                        ? 20
                        : 0
                    )
            } else {
                Color.gray.opacity(0.3)
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(bundle.name)
                    .font(.headline)

                Text("\(bundle.imageCount) images")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text(bundle.createdAt.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(.vertical, 6)
    }
}
