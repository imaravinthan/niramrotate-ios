//
//  ShopDetailsView.swift
//  niramrotate
//
//  Created by aravinthan.selvaraj on 16/12/25.
//
import SwiftUI

struct ShopDetailsView: View {

    let wallpaper: ShopWallpaper

    var body: some View {
        List {
            Section("Image") {
                Text("ID: \(wallpaper.id)")
                Text("Resolution: \(wallpaper.width)x\(wallpaper.height)")
                Text("NSFW: \(wallpaper.purity.contains("nsfw") ? "Yes" : "No")")
//                Text("Size:" \(wallpap))
            }

            Section {
                Link("Open in Browser", destination: wallpaper.fullURL)
            }
        }
        .navigationTitle("Details")
    }
}
