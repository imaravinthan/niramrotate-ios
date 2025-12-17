//
//  ShopPostView.swift
//  niramrotate
//
//  Created by aravinthan.selvaraj on 16/12/25.
//

import SwiftUI

enum ShopPostAction {
    case download
    case share
    case fullscreen
    case details
//    case menu
}

struct ShopPostView: View {
    @State private var showOptions = false
    let wallpaper: ShopWallpaper
//    let onAction: (ShopPostAction) -> Void
    let onOptionsTap: (ShopWallpaper) -> Void

    var body: some View {
        ZStack(alignment: .topTrailing) {
            
            AsyncImage(url: wallpaper.previewURL) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity)
                        .clipped()
                    
                default:
                    Rectangle()
                        .fill(Color.black)
                        .overlay(ProgressView())
                }
            }
            
            Button {
                onOptionsTap(wallpaper)
            } label: {
                Image(systemName: "ellipsis.circle.fill")
                    .font(.title2)
                    .padding()
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
            }
            .padding()
            
            if wallpaper.isNSFW {
                Text("NSFW")
                    .font(.caption2.bold())
                    .foregroundColor(.red)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(.black.opacity(0.7))
                    .clipShape(Capsule())
                    .padding(8)
            }
        }
    }
}
