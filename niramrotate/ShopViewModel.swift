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

    // MARK: - Published

    @Published var wallpapers: [ShopWallpaper] = []
    @Published var filters = ShopFilters()
    @Published var isLoading = false
    @Published var isEmptyResult = false
    @Published private(set) var hasMorePages = true

    // MARK: - Private

    private var page = 1
    private var lastPage = Int.max
    private let prefs = ShopPreferences.shared

    // MARK: - Lifecycle

    func loadInitial() async {
        page = 1
        lastPage = Int.max
        wallpapers.removeAll()
        hasMorePages = true
        isEmptyResult = false
        await loadNext()
    }

    func resetAndReload() async {
        guard !isLoading else { return }
        await loadInitial()
    }

    // MARK: - Pagination (CORRECT)

    func loadNext() async {
        guard !isLoading, hasMorePages else { return }

        isLoading = true

        do {
            let result = try await WallhavenAPI.search(
                filters: filters,
                page: page
            )

            let ordered = applyRatioPreference(result.items)

            wallpapers.append(contentsOf: ordered)

            page = result.currentPage + 1
            lastPage = result.lastPage
            hasMorePages = page <= lastPage

            if wallpapers.isEmpty {
                isEmptyResult = true
            }

        } catch {
            print("❌ Wallhaven fetch failed:", error)
            hasMorePages = false
        }

        isLoading = false
    }

    // MARK: - Seen / Save

    func markSeen(_ wallpaper: ShopWallpaper) {
        prefs.markSeen(wallpaper.id)
    }

    func saveToBundle(wallpaper: ShopWallpaper) {
        // TODO
    }

    // MARK: - Ratio Preference (LOCAL ONLY)

    private func applyRatioPreference(
        _ items: [ShopWallpaper]
    ) -> [ShopWallpaper] {

        guard filters.wantsMixedRatios else {
            return items
        }

        let portraits = items.filter { $0.isPortrait }
        let landscapes = items.filter { $0.isLandscape }

        var result: [ShopWallpaper] = []
        var p = portraits.makeIterator()
        var l = landscapes.makeIterator()

        // 2 portrait : 1 landscape
        while true {
            var added = false

            for _ in 0..<2 {
                if let next = p.next() {
                    result.append(next)
                    added = true
                }
            }

            if let next = l.next() {
                result.append(next)
                added = true
            }

            if !added { break }
        }

        return result
    }
}
