//
//  ShopFeedView.swift
//  niramrotate
//
//  Created by aravinthan.selvaraj on 16/12/25.
//

import SwiftUI

//#Preview("Shop Feed – Static") {
//    ShopFeedView(
//        wallpapers: [
//            .previewPortrait,
//            .previewLandscape,
//            .previewNSFW
//        ],
//        onReachBottom: {
//            // no-op for preview
//        },
//        onOptionsTap: { _ in
//            // no-op for preview
//        },
//        onTagTap: { _ in
//            // no-op for preview
//        },
//        resetAndReload: {
//            // no-op async for preview
//        }
//    )
//}


struct ShopFeedView: View {

    let wallpapers: [ShopWallpaper]
    let hasMorePages: Bool

    let onReachBottom: () -> Void
    let onOptionsTap: (ShopWallpaper) -> Void
    let onImageTap: (ShopWallpaper) -> Void
    let onTagTap: (String) -> Void
    let resetAndReload: () async -> Void

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {

                ForEach(wallpapers) { wp in
                    ShopPostCardView(
                        wallpaper: wp,
                        onOptionsTap: { _ in onOptionsTap(wp) },
                        onImageTap: { _ in onImageTap(wp) }
                    )
                }

                footer
            }
            .padding(.vertical)
            .refreshable {
                await resetAndReload()
            }
        }
    }

    @ViewBuilder
    private var footer: some View {
        if hasMorePages {
            ProgressView()
                .padding()
                .onAppear {
                    onReachBottom()
                }
        } else {
            Text("— You’ve reached the end —")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.vertical, 24)
        }
    }
}

