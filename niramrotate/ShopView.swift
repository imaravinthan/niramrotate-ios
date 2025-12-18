//
//  ShopView.swift
//  niramrotate
//
//  Created by aravinthan.selvaraj on 16/12/25.
//

import SwiftUI

#Preview{
    ShopView()
}

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

                // 🔹 Search Bar (always visible)
                ShopSearchBarView(
                    filters: $vm.filters,
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
                .padding(.bottom, 8)

                // 🔹 Content Area
                Group {
                    if vm.isEmptyResult {
                        VStack {
                            Spacer()
                            Text("No wallpapers found")
                                .foregroundColor(.secondary)
                                .font(.callout)
                                .opacity(0.8)
                            Spacer()
                        }
                    } else if vm.wallpapers.isEmpty {
                        VStack {
                            Spacer()
                            ProgressView("Loading…")
                            Spacer()
                        }
                    } else {
                        ShopFeedView(
                            wallpapers: vm.wallpapers,
                            onReachBottom: {
                                Task { await vm.loadNext() }
                            },
                            onOptionsTap: { wp in
                                selectedWallpaper = wp
                                showActionSheet = true
                            },
                            resetAndReload: {
                                Task { await vm.resetAndReload() }
                            }
                        )
                    }
                }
                .frame(maxWidth: .infinity) //, maxHeight: .infinity)
            }
            .navigationTitle("Shop")
            .navigationBarTitleDisplayMode(.large)
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
