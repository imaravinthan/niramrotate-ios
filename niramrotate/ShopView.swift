//
//  ShopView.swift
//  niramrotate
//
//  Created by aravinthan.selvaraj on 16/12/25.
//

import SwiftUI

struct ShopView: View {

    @StateObject private var vm = ShopViewModel()
    @State private var showFilters = false
    
    @State private var showDetails = false
    @State private var detailsWallpaper: ShopWallpaper?

    @State private var showFullscreen = false
    @State private var fullscreenWallpaper: ShopWallpaper?
    
    @State private var showActionSheet = false
    @State private var selectedWallpaper: ShopWallpaper?
    
    var body: some View {
        NavigationStack {
            ShopFeedView(
                wallpapers: vm.wallpapers,
                onReachBottom: {
                    Task { await vm.loadNext() }
                },
                onOptionsTap: { wp in
                    selectedWallpaper = wp
                    showActionSheet = true
                }
            )
            .navigationTitle("Shop")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        print("Filter button tapped")
                        showFilters.toggle()
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }
                }

                ToolbarItem(placement: .principal) {
                    TextField("Search wallpapers", text: $vm.filters.query)
                        .textFieldStyle(.roundedBorder)
                        .frame(maxWidth: 260)
                        .onSubmit {
                            Task { await vm.loadInitial() }
                        }
                }
            }
        }
        .task {
            await vm.loadInitial()
        }
        .sheet(isPresented: $showDetails) {
            if let wp = detailsWallpaper {
                ShopDetailsView(wallpaper: wp)
            }
        }
        .fullScreenCover(isPresented: $showFullscreen) {
            if let wp = fullscreenWallpaper {
                ShopFullscreenView(wallpaper: wp)
            }
        }
        .overlay(alignment: .bottom) {
            if showActionSheet, let wp = selectedWallpaper {
                ShopActionSheet(
                    wallpaper: wp,
                    onSelect: { action in
                        showActionSheet = false
                        handleAction(action, wallpaper: wp)
                    },
                    onDismiss: {
                        showActionSheet = false
                    }
                )
                .transition(.move(edge: .bottom))
            }
        }
        .animation(.easeOut, value: showActionSheet)

    }

    private func handleAction(
        _ action: ShopPostAction,
        wallpaper: ShopWallpaper
    ) {
        switch action {

//        case .menu:
//            selectedWallpaper = wallpaper
//            showActionSheet = true

        case .download:
            ImageDownloader.saveToPhotos(url: wallpaper.fullURL)

        case .share:
            ShareManager.share(url: wallpaper.fullURL)

        case .fullscreen:
            fullscreenWallpaper = wallpaper
            showFullscreen = true

        case .details:
            detailsWallpaper = wallpaper
            showDetails = true
        }
    }


}
