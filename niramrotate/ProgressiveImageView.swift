//
//  ProgressiveImageView.swift
//  niramrotate
//
//  Created by aravinthan.selvaraj on 18/12/25.
//


import SwiftUI

struct ProgressiveImageView: View {

    let previewURL: URL
    let fullURL: URL
    let wallpaper: ShopWallpaper
    let height: CGFloat

    @State private var fullLoaded = false

    var body: some View {
        GeometryReader { geo in
            ZStack {

                AsyncImage(url: previewURL) { phase in
                    if case .success(let image) = phase {
                        imageView(image, geo: geo)
                            .blur(radius: fullLoaded ? 0 : 20)
                            .opacity(fullLoaded ? 0 : 1)
                    }
                }

                AsyncImage(url: fullURL) { phase in
                    if case .success(let image) = phase {
                        imageView(image, geo: geo)
                            .opacity(fullLoaded ? 1 : 0)
                            .onAppear {
                                withAnimation(.easeOut(duration: 0.25)) {
                                    fullLoaded = true
                                }
                            }
                    }
                }
            }
            .frame(width: geo.size.width, height: geo.size.height)
            .clipped()
        }
        .frame(height: height)
    }

//    @ViewBuilder
//    private func imageView(_ image: Image, geo: GeometryProxy) -> some View {
//        if wallpaper.isPortrait {
//            image
//                .resizable()
//                .scaledToFill()
//                .scaleEffect(1.05)
//        } else {
//            ZStack {
//                image
//                    .resizable()
//                    .scaledToFill()
//                    .blur(radius: 30)
//                    .opacity(0.35)
//
//                image
//                    .resizable()
//                    .scaledToFit()
//            }
//        }
//    }
    @ViewBuilder
    private func imageView(_ image: Image, geo: GeometryProxy) -> some View {
        image
            .resizable()
            .scaledToFill()
            .scaleEffect(1.08) // 🔑 slight zoom (kills black bars)
            .frame(
                width: geo.size.width,
                height: geo.size.height
            )
            .clipped()
    }
}
