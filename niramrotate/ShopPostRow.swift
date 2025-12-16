//
//  ShopPostRow.swift
//  niramrotate
//
//  Created by aravinthan.selvaraj on 16/12/25.
//

import SwiftUI

struct ShopPostRow: View {

    let wallpaper: ShopWallpaper
    @State private var showSheet = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {

            AsyncImage(url: wallpaper.previewURL) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFit()
                        .onTapGesture {
                            showSheet = true
                        }
                case .failure:
                    Color.gray.frame(height: 200)
                default:
                    ProgressView().frame(height: 200)
                }
            }

            HStack {
                Text("\(wallpaper.width)x\(wallpaper.height)")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                if wallpaper.isNSFW {
                    Text("NSFW")
                        .font(.caption2)
                        .foregroundColor(.red)
                }

                Spacer()
            }
            .padding(.horizontal, 8)
        }
        .sheet(isPresented: $showSheet) {
            ActivityView(activityItems: [wallpaper.fullURL])
        }
    }
}
