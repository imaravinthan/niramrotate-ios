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
//        resetAndReload: {
//            // no-op async for preview
//        }
//    )
//}


struct ShopFeedView: View {

    let wallpapers: [ShopWallpaper]
    let onReachBottom: () -> Void
    let onOptionsTap: (ShopWallpaper) -> Void
    let resetAndReload: () async -> Void

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(wallpapers) { wp in
                    ShopPostView(wallpaper: wp) { action in
                        onOptionsTap(wp)
                    }
                }
                ProgressView()
                    .onAppear {
                        onReachBottom()
                    }
            }
            .padding(.vertical)
            .refreshable {
                await resetAndReload()
            }
        }
    }
}  
