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
            VStack(spacing: 0) {
                ShopSearchBarView(
                    query: $vm.filters.query,
                    onSubmit: {
                        Task { await vm.resetAndReload() }
                    },
                    onClear: {
                        Task { await vm.resetAndReload() }
                    },
                    onFilterTap: {
                        showFilters = true
                    }
                )
                
                ShopFeedView(
                    wallpapers: vm.wallpapers,
                    onReachBottom: {
                        Task { await vm.loadNext() }
                    },
                    onOptionsTap: { wp in
                        selectedWallpaper = wp
                        showActionSheet = true
                    },
                    onPullToRefresh:{
                        Task {await vm.resetAndReload() }
                    }
                )
                .navigationTitle("Shop")
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
        .sheet(isPresented: $showFilters) {
            ShopFilterView(
                filters: $vm.filters,
                onApply: {
                    Task { await vm.resetAndReload() }
                    showFilters = false
                }
            )
        }
    }

    private func handleAction(
        _ action: ShopPostAction,
        wallpaper: ShopWallpaper
    ) {
        switch action {

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
