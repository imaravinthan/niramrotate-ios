//
//  ShopFeedView.swift
//  niramrotate
//
//  Created by aravinthan.selvaraj on 16/12/25.
//

import SwiftUI

struct ShopFeedView: View {

    let wallpapers: [ShopWallpaper]
    let onReachBottom: () -> Void
    let onOptionsTap: (ShopWallpaper) -> Void

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
        }
    }
}
