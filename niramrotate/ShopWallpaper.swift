//
//  ShopWallpaper.swift
//  niramrotate
//
//  Created by aravinthan.selvaraj on 16/12/25.
//
import SwiftUI
import Foundation

struct ShopWallpaper: Identifiable {
    let id: String
    
    // MARK: - URL
    let previewURL: URL
    let fullURL: URL
    let webURL: URL
    
    // MARK: - Meta
    let views: Int
    let favorites: Int
    let purity: String
    let category: String
    
    let width: Int
    let height: Int
    let ratio: String
    
    let fileSize: Int
    let fileType: String
    let createdAt: String
    
    // 🔑 OPTIONAL (filled only if API key exists)
    var uploader: String? = nil
    var tags: [ShopTag]? = nil
    // MARK: - Orientation helpers

    var isPortrait: Bool {
        height > width
    }

    var isLandscape: Bool {
        width > height
    }

    var isSquare: Bool {
        width == height
    }
    
    /// Treat sketchy + nsfw as NSFW (your decision)
    var isNSFW: Bool {
        purity == "sketchy" || purity == "nsfw"
    }
    
    var fileSizeMB: String {
        String(format: "%2f MB", Double(fileSize)/1_048_576)
    }
}


struct ShopImageView: View {
    let previewURL: URL

    var body: some View {
        ZStack {
            Color.black

            AsyncImage(url: previewURL) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                ProgressView()
            }
        }
        .frame(
            width: UIScreen.main.bounds.width,
            height: UIScreen.main.bounds.height
        )
        .clipped()
        .ignoresSafeArea()
    }
}

struct FullscreenRemoteImage: View {
    let url: URL

    var body: some View {
        GeometryReader { geo in
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image
//                        .resizable()
//                        .scaledToFit()
//                        .frame(maxWidth: .infinity, maxHeight: .infinity)
//                        .background(Color.black)
//                        .frame(
//                            width: geo.size.width,
//                            height: geo.size.height
//                        )
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .clipped()

                case .failure:
                    Color.black

                default:
                    ProgressView()
                }
            }
            .frame(
                width: geo.size.width,
                height: geo.size.height
            )
        }
        .ignoresSafeArea()
        .background(Color.black)
    }
}
