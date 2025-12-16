//
//  ShopViewModel.swift
//  niramrotate
//
//  Created by aravinthan.selvaraj on 16/12/25.
//
import SwiftUI
import Combine

@MainActor
final class ShopViewModel: ObservableObject {

    @Published var wallpapers: [ShopWallpaper] = []
    @Published var index: Int = 0
    @Published var isLoading = false
    @Published var filters = ShopSearchFilters()

    private var page = 1

    var currentWallpaper: ShopWallpaper? {
        guard index < wallpapers.count else { return nil }
        return wallpapers[index]
    }

    // MARK: - Lifecycle

    func loadInitial() async {
        await resetAndReload()
    }

    func resetAndReload() async {
        wallpapers.removeAll()
        index = 0
        page = 1
        await loadNextPage()
    }

    func loadNextPage() async {
        guard !isLoading else { return }
        isLoading = true

        do {
            let fetched = try await WallhavenAPI.fetchWallpapers(
                page: page,
                filters: filters
            )

            let unseen = fetched.filter {
                !ShopPreferences.shared.hasSeen($0.id)
            }

            wallpapers.append(contentsOf: unseen)
            page += 1
        } catch {
            print("❌ Wallhaven error:", error)
        }

        isLoading = false
    }

    func next() async {
        guard index + 1 < wallpapers.count else { return }

        let current = wallpapers[index]
        ShopPreferences.shared.markSeen(current.id)

        index += 1

        if index >= wallpapers.count - 3 {
            await loadNextPage()
        }
    }
    
    func loadNextPageIfNeeded() async {
            await loadNextPage()
        }
}
