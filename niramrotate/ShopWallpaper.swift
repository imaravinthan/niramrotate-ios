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
    let previewURL: URL
    let fullURL: URL
    let width: Int
    let height: Int
    let purity: String
    let ratio: String
    
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
