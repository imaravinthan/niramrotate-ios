//
//  ShopPostView.swift
//  niramrotate
//
//  Created by aravinthan.selvaraj on 16/12/25.
//

import SwiftUI

struct ShopPostView: View {

    let wallpaper: ShopWallpaper
    @State private var showActions = false

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            AsyncImage(url: wallpaper.fullURL) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black)
                        .onTapGesture {
                            showActions = true
                        }

                default:
                    ProgressView().tint(.white)
                }
            }
        }
        .confirmationDialog("Wallpaper", isPresented: $showActions) {
            Button("Download") {
                // implement later
            }
            Button("Share") {
                // implement later
            }
            Button("Cancel", role: .cancel) {}
        }
    }
}
