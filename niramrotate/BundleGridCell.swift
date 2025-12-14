//
//  BundleGridCell.swift
//  niramrotate
//
//  Created by aravinthan.selvaraj on 14/12/25.
//
import SwiftUI

struct BundleGridCell: View {

    let bundle: ImageBundle

    var body: some View {
        ZStack {
            if let image = ImageBundleStore.shared
                .loadRandomDecryptedImage(forID: bundle.id) {

                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                Color.black.opacity(0.25)
            }
        }
        .frame(height: 220)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .clipped()
    }
}
