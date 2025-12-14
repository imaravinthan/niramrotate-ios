//
//  BundleViewerView.swift
//  niramrotate
//
//  Created by aravinthan.selvaraj on 14/12/25.
//
import SwiftUI

struct BundleViewerView: View {
    let bundle: ImageBundle

    @State private var images: [UIImage] = []
    @State private var index = 0

    var body: some View {
        ZStack {
            if !images.isEmpty {
                Image(uiImage: images[index])
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                    .onTapGesture {
                        index = (index + 1) % images.count
                    }
            }
        }
        .onAppear {
            images = ImageBundleStore.shared
                .listEncryptedImages(for: bundle)
                .compactMap {
                    try? SecureFileStore.shared.loadDecrypted(from: $0)
                }
                .compactMap { UIImage(data: $0) }
        }
    }
}
