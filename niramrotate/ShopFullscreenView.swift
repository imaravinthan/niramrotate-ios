//
//  ShopFullscreenView.swift
//  niramrotate
//
//  Created by aravinthan.selvaraj on 16/12/25.
//

import SwiftUI

#Preview("Fullscreen – Portrait") {
    ShopFullscreenView(
        wallpaper: .previewPortrait
    )
}

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
                    
                    Button{
                      dismiss()
                    } label: {
                        Image(systemName: "arrow.forward.folder.fill")
                            .foregroundColor(.white)
                            .padding(10)
                            .background(.black.opacity(0.5))
                            .clipShape(Capsule())
                    }
                }
                .padding()

                Spacer()
            }

//            VStack {
//                
//                Spacer()
////                Text("\(wallpaper.width)x\(wallpaper.height)")
////                    .font(.caption)
////                    .foregroundColor(.white)
////                    .padding()
////                    .background(.black.opacity(0.6))
//            }
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

struct ShopImageFullscreenView: View {
    let imageURL: URL
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack(alignment: .topLeading) {
            Color.black.ignoresSafeArea()

            AsyncImage(url: imageURL) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black)
                default:
                    ProgressView().tint(.white)
                }
            }

            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.down")
                    .foregroundColor(.white)
                    .padding()
                    .background(.black.opacity(0.5))
                    .clipShape(Circle())
                    .padding()
            }
        }
        .statusBarHidden(true)
    }
}
