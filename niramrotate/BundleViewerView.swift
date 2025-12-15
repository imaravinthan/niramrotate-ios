//
//  BundleViewerView.swift
//  niramrotate
//
//  Created by aravinthan.selvaraj on 14/12/25.
//
import SwiftUI

struct BundleViewerView: View {
    let bundle: ImageBundle

    var body: some View {
        TabView {
            ForEach(
                ImageBundleStore.shared.listEncryptedImages(forID: bundle.id),
                id: \.self
            ) { url in
                if let image = try? SecureFileStore.shared.loadDecrypted(from: url),
                   let ui = UIImage(data: image) {
                    Image(uiImage: ui)
                        .resizable()
                        .scaledToFill()
                        .ignoresSafeArea()
                }
            }
        }
        .tabViewStyle(.page)
    }
}

//import SwiftUI
//import PhotosUI
//
//struct BundleViewerView: View {
//    let bundle: ImageBundle
//
//    @State private var images: [UIImage] = []
//    @State private var currentIndex = 0
//    @State private var showPicker = false
//
//    var body: some View {
//        ZStack {
//            if !images.isEmpty {
//                Image(uiImage: images[currentIndex])
//                    .resizable()
//                    .scaledToFill()
//                    .ignoresSafeArea()
//                    .onTapGesture {
//                        nextImage()
//                    }
//            } else {
//                Color.black.ignoresSafeArea()
//            }
//
//            VStack {
//                // TOP — delete
//                HStack {
//                    Spacer()
//                    Button(role: .destructive) {
//                        deleteCurrentImage()
//                    } label: {
//                        Image(systemName: "trash")
//                            .padding()
//                            .background(.black.opacity(0.6))
//                            .clipShape(Circle())
//                    }
//                }
//                .padding(.top, 50)
//                .padding(.trailing)
//
//                Spacer()
//
//                // BOTTOM — add
//                Button {
//                    showPicker = true
//                } label: {
//                    Image(systemName: "plus")
//                        .font(.largeTitle)
//                        .padding()
//                        .background(.black.opacity(0.6))
//                        .clipShape(Circle())
//                }
//                .padding(.bottom, 40)
//            }
//        }
//        .onAppear {
//            loadImages()
//        }
//        .photosPicker(isPresented: $showPicker, selection: .constant([]), matching: .images)
//    }
//
//    // MARK: - Logic
//
//    private func loadImages() {
//        images = ImageBundleStore.shared
//            .listEncryptedImages(forID: bundle.id)
//            .compactMap {
//                try? SecureFileStore.shared.loadDecryptedImage(from: $0)
//            }
//    }
//
//    private func nextImage() {
//        guard !images.isEmpty else { return }
//        currentIndex = (currentIndex + 1) % images.count
//    }
//
//    private func deleteCurrentImage() {
//        guard images.indices.contains(currentIndex) else { return }
//
//        ImageBundleStore.shared.deleteEncryptedImage(
//            currentIndex,
//            from: bundle.id
//        )
//
//        loadImages()
//        currentIndex = min(currentIndex, images.count - 1)
//    }
//}
