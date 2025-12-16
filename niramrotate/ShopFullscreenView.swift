//
//  ShopFullscreenView.swift
//  niramrotate
//
//  Created by aravinthan.selvaraj on 16/12/25.
//

import SwiftUI

struct ShopFullscreenView: View {

    let wallpaper: ShopWallpaper

    @Environment(\.dismiss) private var dismiss
    @State private var showShareSheet = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            AsyncImage(url: wallpaper.fullURL) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .onLongPressGesture {
                            showShareSheet = true
                        }

                case .failure:
                    Text("Failed to load")
                        .foregroundColor(.white)

                default:
                    ProgressView()
                        .tint(.white)
                }
            }

            VStack {
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.white)
                            .padding(10)
                            .background(.black.opacity(0.5))
                            .clipShape(Circle())
                    }

                    Spacer()
                }
                .padding()

                Spacer()
            }

            VStack {
                Spacer()
                Text("\(wallpaper.width)x\(wallpaper.height)")
                    .font(.caption)
                    .foregroundColor(.white)
                    .padding()
                    .background(.black.opacity(0.6))
            }
        }
        .statusBarHidden(true)
        .toolbar(.hidden, for: .tabBar)
        .sheet(isPresented: $showShareSheet) {
            ActivityView(activityItems: [wallpaper.fullURL])
        }
        .onAppear {
            ShopPreferences.shared.markSeen(wallpaper.id)
        }
    }
}
