//
//  ShopView.swift
//  niramrotate
//
//  Created by aravinthan.selvaraj on 16/12/25.
//

import SwiftUI

//#Preview{
//    ShopView()
//}

enum FullscreenDestination: Identifiable {
    case image(URL)
    case fullDetails(ShopWallpaper)

    var id: String {
        switch self {
        case .image(let url):
            return "image-\(url.absoluteString)"
        case .fullDetails(let wp):
            return "details-\(wp.id)"
        }
    }
}


struct ShopView: View {

    @StateObject private var vm = ShopViewModel()
    @State private var showFilters = false
    
    @State private var showDetails = false
    @State private var detailsWallpaper: ShopWallpaper?
    
    @State private var showActionSheet = false
    @State private var selectedWallpaper: ShopWallpaper?
    @State private var downloadStatus: DownloadStatus = .idle
    
    @State private var fullscreenDestination: FullscreenDestination?
    @State private var dismissTask: Task<Void, Never>?

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
                            hasMorePages: vm.hasMorePages,
                            onReachBottom: {
                                Task { await vm.loadNext() }
                            },
                            onOptionsTap: { wp in
                                selectedWallpaper = wp
                                showActionSheet = true
                            },
                            onImageTap: { wp in
                                fullscreenDestination = .image(wp.fullURL)
                            },
                            onTagTap: { tag in
                                vm.filters.query = tag
                                Task { await vm.resetAndReload() }
                            },
                            resetAndReload: {
                                Task { await vm.resetAndReload() }
                            }
                        )
                    }
                }
            }
            .navigationTitle("Discover")
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
        .fullScreenCover(item: $fullscreenDestination) { destination in
            switch destination {

            case .image(let url):
                ShopImageFullscreenView(imageURL: url)

            case .fullDetails(let wp):
                ShopFullDetailsView(
                    wallpaper: wp,
                    onTagSelected: { tag in
                        vm.filters.query = tag
                        Task { await vm.resetAndReload() }
                    }
                )
            }
        }
        .overlay {

            ZStack {

                // 🔝 TOP: Download status banner
                if downloadStatus != .idle {
                    VStack {
                        DownloadStatusBanner(
                            status: downloadStatus,
                            onDismiss: {
                                withAnimation {
                                    downloadStatus = .idle
                                }
                            }
                        )
                        .padding(.top, 8)

                        Spacer()
                    }
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .zIndex(2)
                }

                // 🔽 BOTTOM: Action sheet
                if showActionSheet, let wp = selectedWallpaper {
                    VStack {
                        Spacer()

                        ShopActionSheet(
                            wallpaper: wp,
                            hasAPIKey: ShopPreferences.shared.hasWallhavenKey,
                            onSelect: { action in
                                showActionSheet = false
                                handleAction(action, wallpaper: wp)
                            },
                            onDismiss: {
                                showActionSheet = false
                            }
                        )
                    }
                    .transition(.move(edge: .bottom))
                    .zIndex(1)
                }
            }
        }
        .animation(.easeInOut, value: downloadStatus)
        .animation(.easeOut, value: showActionSheet)
        .onChange(of: downloadStatus) { newStatus in
            dismissTask?.cancel()

            guard newStatus.shouldAutoDismiss else { return }

            dismissTask = Task {
                try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
                await MainActor.run {
                    withAnimation {
                        downloadStatus = .idle
                    }
                }
            }
        }
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
//            ImageSaveManager.save(
//                imageURL: wallpaper.fullURL,
//                status: { newStatus in
//                    downloadStatus = newStatus
//                }
//            )
            ImageSaveManager.save(
                    imageURL: wallpaper.fullURL,
                    status: { downloadStatus = $0 }
            )
        case .share:
            ShareManager.share(url: wallpaper.fullURL)

        case .showOriginal:
            if ShopPreferences.shared.hasWallhavenKey {
                fullscreenDestination = .fullDetails(wallpaper)
            } else {
                fullscreenDestination = .image(wallpaper.fullURL)
            }
        case .details:
            detailsWallpaper = wallpaper
            showDetails = true
        }
    }

}

struct DownloadStatusBanner: View {

    let status: DownloadStatus
    let onDismiss: () -> Void

    var body: some View {
            HStack(spacing: 12) {

                ProgressView()
                    .opacity(status == .downloading ? 1 : 0)

                Text(status.label)
                    .font(.caption)
                    .lineLimit(1)

                Spacer()

                Button {
                    onDismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.caption2)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(.ultraThinMaterial)
            .clipShape(Capsule())
            .shadow(radius: 8)
            .padding(.horizontal)
    }

    private var icon: some View {
        Group {
            switch status {
            case .downloading:
                ProgressView()
                    .progressViewStyle(.circular)
                    .tint(.white)

            case .downloaded:
                Image(systemName: "checkmark.circle.fill")

            case .saved:
                Image(systemName: "photo.fill")

            case .failed:
                Image(systemName: "exclamationmark.triangle.fill")
                
            case .saving:
                ProgressView()
                    .progressViewStyle(.circular)
                    .tint(.white)
                
            case .idle:
                EmptyView()
            }
        }
        .foregroundColor(.white)
    }

    private var backgroundColor: Color {
        switch status {
        case .failed:
            return .red.opacity(0.9)
        case .downloading:
            return .black.opacity(0.85)
        default:
            return .green.opacity(0.9)
        }
    }
}
