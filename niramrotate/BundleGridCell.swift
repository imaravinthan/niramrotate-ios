//
//  BundleGridCell.swift
//  niramrotate
//
//  Created by aravinthan.selvaraj on 14/12/25.
//
import SwiftUI

struct BundleGridCell: View {

    let bundle: ImageBundle
    let thumbnail: UIImage?

    var body: some View {
        VStack {
            if let image = ImageBundleStore.shared.loadRandomThumbnail(for: bundle) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                Color.gray.opacity(0.3)
            }
        }
        .frame(height: 140)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
