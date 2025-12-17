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
    @Published private(set) var hasMorePages = true
    @Published var isEmptyResult = false

    private var page = 1
    private let pageSize = 24
    private let prefs = ShopPreferences.shared

    func loadInitial() async {
        page = 1
        wallpapers.removeAll()
        hasMorePages = true
        isEmptyResult = false

        await loadNext()
    }


    func loadNext() async {
        guard !isLoading else { return }
        guard hasMorePages else { return }

        isLoading = true

        do {
            let response = try await WallhavenAPI.fetch(
                filters: filters,
                page: page
            )

            if response.isEmpty {
                hasMorePages = false
                isEmptyResult = wallpapers.isEmpty
            } else {
                wallpapers.append(contentsOf: response)
                page += 1
            }

        } catch {
            print("❌ Fetch failed:", error)
            hasMorePages = false
        }

        isLoading = false
    }



    func markSeen(_ wallpaper: ShopWallpaper) {
        prefs.markSeen(wallpaper.id)
    }
    
    func resetAndReload() async{
        guard !isLoading else { return }
        await loadInitial()
    }
}
