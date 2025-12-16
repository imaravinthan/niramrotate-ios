//
//  BundleViewerView.swift
//  niramrotate
//
//  Created by aravinthan.selvaraj on 14/12/25.
//
// ---- working fix ----
//import SwiftUI
//
//struct BundleViewerView: View {
//    let bundle: ImageBundle
//
//    var body: some View {
//        TabView {
//            ForEach(
//                ImageBundleStore.shared.listEncryptedImages(forID: bundle.id),
//                id: \.self
//            ) { url in
//                if let image = try? SecureFileStore.shared.loadDecrypted(from: url),
//                   let ui = UIImage(data: image) {
//                    Image(uiImage: ui)
//                        .resizable()
//                        .scaledToFill()
//                        .ignoresSafeArea()
//                }
//            }
//        }
//        .tabViewStyle(.page)
//    }
//}
// ---- end ---

import SwiftUI
import PhotosUI

struct BundleViewerView: View {

    let bundle: ImageBundle

    @State private var images: [URL] = []
    @State private var index: Int = 0

    @State private var showDeleteConfirm = false
    @State private var showPicker = false
    @State private var pickerItems: [PhotosPickerItem] = []
    @Environment(\.dismiss) private var dismiss
    

    var body: some View {
        ZStack {
            currentImageView
//                .gesture(horizontalSwipe)
//                .gesture(verticalSwipe)
//                .gesture(unifiedSwipeGesture)
        }
//        .gesture(unifiedSwipeGesture)
        .simultaneousGesture(unifiedSwipeGesture)
        .ignoresSafeArea(edges: [.leading, .trailing])
//        .ignoresSafeArea()
        .navigationBarHidden(true)
//        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
        .statusBarHidden(true)
        .onAppear(perform: loadImages)
        .photosPicker(
            isPresented: $showPicker,
            selection: $pickerItems,
            matching: .images
        )
        .onChange(of: pickerItems) { _ in
            Task { await handlePickedImages() }
        }
        .alert("Delete image?", isPresented: $showDeleteConfirm) {
            Button("Delete", role: .destructive) {
                deleteCurrent()
            }
            Button("Cancel", role: .cancel) {}
        }
        .overlay(alignment: .topLeading) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.title2.bold())
                    .foregroundStyle(.white)
                    .padding(12)
                    .background(.black.opacity(0.4))
                    .clipShape(Circle())
            }
            .padding(.leading, 12)
            .padding(.top, 12)
        }
//        .overlay(alignment: .bottom) {
//            HStack(spacing: 6) {
//                ForEach(images.indices, id: \.self) { i in
//                    Circle()
//                        .fill(i == index ? .white : .white.opacity(0.4))
//                        .frame(width: 6, height: 6)
//                }
//            }
//            .padding(.bottom, 24)
//        }
        .overlay(alignment: .bottom) {
            VStack {
                Spacer()
                Text("\(index + 1) / \(images.count)")
                    .font(.caption)
                    .padding(8)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
                    .padding(.bottom, 30)
            }
        }

    }

    // MARK: - Image View

    private var currentImageView: some View {
        Group {
            if index < images.count,
               let data = try? SecureFileStore.shared.loadDecrypted(from: images[index]),
               let image = UIImage(data: data) {

//                Image(uiImage: image)
//                    .resizable()
//                    .scaledToFill()
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                    .contentShape(Rectangle()) // ← REQUIRED


            } else {
                Color.black
            }
        }
    }

    // MARK: - Gestures

    private var horizontalSwipe: some Gesture {
        DragGesture(minimumDistance: 20)
            .onEnded { value in
                guard abs(value.translation.width) > abs(value.translation.height) else { return }

                if value.translation.width < -50 {
                    nextImage()
                } else if value.translation.width > 50 {
                    previousImage()
                }
            }
    }

    private var verticalSwipe: some Gesture {
        DragGesture(minimumDistance: 20)
            .onEnded { value in
                guard abs(value.translation.height) > abs(value.translation.width) else { return }

                if value.translation.height < -80 {
                    // swipe UP
                    openPhotoPicker()
                } else if value.translation.height > 80 {
                    // swipe DOWN
                    showDeleteConfirm = true
                }
            }
    }

    // MARK: - Navigation

    private func nextImage() {
        guard !images.isEmpty else { return }
        index = (index + 1) % images.count
    }

    private func previousImage() {
        guard !images.isEmpty else { return }
        index = (index - 1 + images.count) % images.count
    }
    
    private var edgeBackGesture: some Gesture {
        DragGesture(minimumDistance: 30)
            .onEnded { value in
                if value.startLocation.x < 20 && value.translation.width > 80 {
                    dismiss()
                }
            }
    }

    
    // MARK: - Data

    private func loadImages() {
        images = ImageBundleStore.shared.listEncryptedImages(forID: bundle.id)
        index = min(index, max(images.count - 1, 0))
    }

    private func deleteCurrent() {
        guard index < images.count else { return }

        do {
            try ImageBundleStore.shared.deleteEncryptedImage(
                images[index],
                from: bundle
            )
            images.remove(at: index)
            index = max(0, index - 1)
        } catch {
            print("❌ Delete failed:", error)
        }
    }

    // MARK: - Photo Picker

    private func openPhotoPicker() {
        showPicker = true
    }

    private func handlePickedImages() async {
        guard !pickerItems.isEmpty else { return }

        do {
            for item in pickerItems {
                guard
                    let data = try? await item.loadTransferable(type: Data.self)
                else { continue }

                try ImageBundleStore.shared.addEncryptedImage(data, to: bundle)
            }

            pickerItems.removeAll()
            loadImages()

        } catch {
            print("❌ Add image failed:", error)
        }
    }
    
//    System Swipe from left edge
//    private var unifiedSwipeGesture: some Gesture {
//        DragGesture(minimumDistance: 30)
//            .onEnded { value in
//                let horizontal = value.translation.width
//                let vertical = value.translation.height
//
//                // Ignore gestures near system edges
//                if value.startLocation.y < 80 || value.startLocation.y > UIScreen.main.bounds.height - 100 {
//                    return
//                }
//
//                if abs(horizontal) > abs(vertical) {
//                    if horizontal < -80 {
//                        nextImage()
//                    } else if horizontal > 80 {
//                        previousImage()
//                    }
//                } else {
//                    if vertical < -120 {
//                        openPhotoPicker()   // swipe UP
//                    } else if vertical > 120 {
//                        showDeleteConfirm = true // swipe DOWN
//                    }
//                }
//            }
//    }
// Properly working
//    private var unifiedSwipeGesture: some Gesture {
//        DragGesture(minimumDistance: 30, coordinateSpace: .local)
//            .onEnded { value in
//                let horizontal = value.translation.width
//                let vertical = value.translation.height
//
//                // Ignore edge swipes (allow system back)
//                if value.startLocation.x < 20 {
//                    return
//                }
//
//                if abs(horizontal) > abs(vertical) {
//                    if horizontal < -80 {
//                        nextImage()
//                    } else if horizontal > 80 {
//                        previousImage()
//                    }
//                } else {
//                    if vertical < -120 {
//                        openPhotoPicker()
//                    } else if vertical > 120 {
//                        showDeleteConfirm = true
//                    }
//                }
//            }
//    }
    private var unifiedSwipeGesture: some Gesture {
        DragGesture(minimumDistance: 25)
            .onEnded { value in
                let horizontal = value.translation.width
                let vertical = value.translation.height

                if abs(horizontal) > abs(vertical) {
                    if horizontal < -60 {
                        nextImage()
                        HapticManager.impact(.light)
                    } else if horizontal > 60 {
                        previousImage()
                        HapticManager.impact(.light)
                    }
                } else {
                    if vertical < -80 {
                        openPhotoPicker()
                        HapticManager.impact(.medium)
                    } else if vertical > 80 {
                        showDeleteConfirm = true
                        HapticManager.notification(.warning)
                    }
                }
            }
    }


}
