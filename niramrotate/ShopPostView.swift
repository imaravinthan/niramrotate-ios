//
//  ShopPostView.swift
//  niramrotate
//
//  Created by aravinthan.selvaraj on 16/12/25.
//

import SwiftUI

//#Preview("Shop view"){
//    ShopPostView(
//        wallpaper: .previewLandscape,
//        onOptionsTap: { _ in
//               // no-op for preview
//        }
//    )
//}

enum ShopPostAction {
    case download
    case share
    case fullscreen
    case details
}

struct ShopPostView: View {
    let wallpaper: ShopWallpaper
    let onOptionsTap: (ShopWallpaper) -> Void
    private var calculatedHeight: CGFloat {
        let screenWidth = UIScreen.main.bounds.width - 32 // padding
        let aspectRatio = CGFloat(wallpaper.height) / CGFloat(wallpaper.width)
        return screenWidth * aspectRatio
    }
    private var cardHeight: CGFloat {
        let screenWidth = UIScreen.main.bounds.width - 32 // padding
        let aspect = CGFloat(wallpaper.height) / CGFloat(wallpaper.width)

        // Clamp extreme ratios (VERY IMPORTANT)
        let clampedAspect = min(max(aspect, 0.7), 1.8)

        return screenWidth * clampedAspect
    }
    private var imageContainer: some View {
        ProgressiveImageView(
            previewURL: wallpaper.previewURL,
            fullURL: wallpaper.fullURL,
            wallpaper: wallpaper,
            height: cardHeight
        )
    }

    var body: some View {
//        VStack(spacing: 0) {

        ZStack(alignment: .topTrailing) {

            imageContainer

            optionsButton
            nsfwBadge
        }
//        }
        .background(Color.black)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .padding(.horizontal)
    }
    
//    private var imageContainer: some View {
//        GeometryReader { geo in
//            AsyncImage(url: wallpaper.fullURL) { phase in
//                switch phase {
//                case .success(let image):
//                    image
//                        .resizable()
//                        .scaledToFill()
//                        .scaleEffect(1.08) // 🔑 slight zoom (kills black bars)
//                        .frame(
//                            width: geo.size.width,
//                            height: geo.size.height
//                        )
//                        .clipped()
//
//                default:
//                    Color.black
//                        .overlay(ProgressView())
//                }
//            }
//        }
//        .frame(height: cardHeight)
//    }

    
    private var optionsButton: some View {
        VStack {
            HStack {
                Spacer()
                Button {
                    onOptionsTap(wallpaper)
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.title2)
                        .padding(8)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                }
            }
            Spacer()
        }
        .padding()
    }

    private var nsfwBadge: some View {
        Group {
            if wallpaper.isNSFW {
                VStack {
                    HStack {
                        Text("NSFW")
                            .font(.caption2.bold())
                            .foregroundColor(.red)
                            .padding(6)
                            .background(.black.opacity(0.7))
                            .clipShape(Capsule())
                        Spacer()
                    }
                    Spacer()
                }
                .padding(8)
            }
        }
    }


}
