//
//  ShopPostView.swift
//  niramrotate
//
//  Created by aravinthan.selvaraj on 16/12/25.
//

//import SwiftUI
//
//struct ShopPostView: View {
//
//    let wallpaper: ShopWallpaper
//    @State private var showActions = false
//    @State private var showShareSheet = false
//    @State private var activityItems: [Any] = []
//    @State private var isDownloading = false
//
//    var body: some View {
//        ZStack(alignment: .bottomTrailing) {
//            AsyncImage(url: wallpaper.fullURL) { phase in
//                switch phase {
//                case .success(let image):
//                    image
//                        .resizable()
//                        .scaledToFit()
//                        .onTapGesture {
//                            showActions = true
//                        }
//
//                case .failure:
//                    Text("Failed to load")
//                        .foregroundColor(.white)
//
//                default:
//                    ProgressView().tint(.white)
//                }
//            }
//
//        }
//        .confirmationDialog(
//            "Wallpaper Options",
//            isPresented: $showActions,
//            titleVisibility: .visible
//        ) {
//
//            Button("Save to Photos") {
//                saveToPhotos()
//            }
//
//            Button("Download to Files") {
//                downloadToFiles()
//            }
//
//            Button("Share") {
//                activityItems = [wallpaper.fullURL]
//                showShareSheet = true
//            }
//
//            Button("Cancel", role: .cancel) {}
//        }
//        .sheet(isPresented: $showShareSheet) {
//            ActivityView(activityItems: activityItems)
//        }
//    }
//    
//    private func saveToPhotos() {
//        Task {
//            do {
//                let (data, _) = try await URLSession.shared.data(from: wallpaper.fullURL)
//                if let image = UIImage(data: data) {
//                    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
//                }
//            } catch {
//                print("❌ Save to photos failed:", error)
//            }
//        }
//    }
//    
//    private func downloadToFiles() {
//        Task {
//            do {
//                let (data, _) = try await URLSession.shared.data(from: wallpaper.fullURL)
//
//                let tempURL = FileManager.default.temporaryDirectory
//                    .appendingPathComponent("\(wallpaper.id).jpg")
//
//                try data.write(to: tempURL)
//
//                DispatchQueue.main.async {
//                    let picker = UIDocumentPickerViewController(
//                        forExporting: [tempURL]
//                    )
//                    UIApplication.shared.topViewController?
//                        .present(picker, animated: true)
//                }
//
//            } catch {
//                print("❌ File download failed:", error)
//            }
//        }
//    }
//
//}
import SwiftUI
import Foundation
import Photos
import UIKit

enum ImageDownloader {

    static func saveToPhotos(url: URL) {
        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)

                guard let image = UIImage(data: data) else {
                    print("❌ Invalid image data")
                    return
                }

                await requestPhotoPermission()

                UIImageWriteToSavedPhotosAlbum(
                    image,
                    nil,
                    nil,
                    nil
                )
                
                print("✅ Saved to Photos")

            } catch {
                print("❌ Download failed:", error)
            }
        }
    }

    private static func requestPhotoPermission() async {
        let status = PHPhotoLibrary.authorizationStatus(for: .addOnly)

        if status == .notDetermined {
            await PHPhotoLibrary.requestAuthorization(for: .addOnly)
        }
    }
}


enum ShareManager {

    static func share(url: URL) {
        guard let topVC = UIApplication.shared.topViewController else {
            return
        }

        let activityVC = UIActivityViewController(
            activityItems: [url],
            applicationActivities: nil
        )

        topVC.present(activityVC, animated: true)
    }
}


struct ShopPostView: View {

    let wallpapers: [ShopWallpaper]
    let onReachBottom: () -> Void

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(wallpapers.indices, id: \.self) { index in
                    PostCell(wallpaper: wallpapers[index])
                        .onAppear {
                            if index == wallpapers.count - 2 {
                                onReachBottom()
                            }
                        }
                }
            }
        }
        .scrollIndicators(.hidden)
        .ignoresSafeArea()
    }
}

private struct PostCell: View {

    let wallpaper: ShopWallpaper
    @State private var showActions = false

    var body: some View {
        VStack(spacing: 0) {
            AsyncImage(url: wallpaper.previewURL) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFit()
                        .onTapGesture {
                            showActions = true
                        }

                case .failure:
                    Color.black.frame(height: 300)

                default:
                    ProgressView().frame(height: 300)
                }
            }
        }
        .confirmationDialog("Options", isPresented: $showActions) {
            Button("Download") {
                download()
            }
            Button("Share") {
                share()
            }
            Button("Cancel", role: .cancel) {}
        }
    }

    private func download() {
        ImageDownloader.saveToPhotos(url: wallpaper.fullURL)
    }

    private func share() {
        ShareManager.share(url: wallpaper.fullURL)
    }
}
