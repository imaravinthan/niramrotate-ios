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
    @Published var filters = ShopFilters()
    @Published var isLoading = false

    private var page = 1
    private let prefs = ShopPreferences.shared

    func loadInitial() async {
        wallpapers.removeAll()
        page = 1
        await loadNext()
    }

    func loadNext() async {
        guard !isLoading else { return }
        isLoading = true

        do {
            let prefs = ShopPreferences.shared
            let fetched = try await WallhavenAPI.fetch(
                filters: filters,
                page: page
            )

            let unseen = fetched.filter { !prefs.hasSeen($0.id) }
            wallpapers.append(contentsOf: unseen)
            page += 1
        } catch {
            print("❌ Fetch failed:", error)
        }

        isLoading = false
    }

    func markSeen(_ wallpaper: ShopWallpaper) {
        prefs.markSeen(wallpaper.id)
    }
    
    func resetAndReload() async{
        await loadInitial()
    }
}
