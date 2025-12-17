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
    @Published var isEmptyResult = false
    @Published private(set) var hasMorePages = true

    private var page = 1
    private let prefs = ShopPreferences.shared

    func loadInitial() async {
        page = 1
        wallpapers.removeAll()
        hasMorePages = true
        isEmptyResult = false
        await loadNext()
    }

    func loadNext() async {
        guard !isLoading, hasMorePages else { return }

        isLoading = true

        do {
            
            let fetched = try await WallhavenAPI.fetch(
                filters: filters,
                page: page
            )

            let strictlyFiltered = fetched.filter { wp in
                switch filters.purity {
                case .sfw:
                    return wp.purity == "sfw"
                case .nsfw:
                    return true
                }
            }

            if strictlyFiltered.isEmpty {
                hasMorePages = false
                isEmptyResult = wallpapers.isEmpty
            } else {
                let ordered = applyRatioPriority(strictlyFiltered)
                wallpapers.append(contentsOf: ordered)

//                wallpapers.append(contentsOf: strictlyFiltered)
                page += 1
            }

        } catch {
            print("❌ Wallhaven fetch failed:", error)
            hasMorePages = false
        }

        isLoading = false
    }

    func resetAndReload() async {
        guard !isLoading else { return }
        await loadInitial()
    }

    func markSeen(_ wallpaper: ShopWallpaper) {
        prefs.markSeen(wallpaper.id)
    }
    private func applyRatioPriority(
        _ items: [ShopWallpaper]
    ) -> [ShopWallpaper] {

        let portraits = items.filter { $0.height > $0.width }
        let landscapes = items.filter { $0.width >= $0.height }

        guard filters.wantsMixedRatios else {
            return items
        }

        var result: [ShopWallpaper] = []
        var p = portraits.makeIterator()
        var l = landscapes.makeIterator()

        // 3 portrait : 1 landscape pattern
        while true {
            var added = false

            for _ in 0..<3 {
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

    
    private func mergePortraitPriority(
        existing: [ShopWallpaper],
        incoming: [ShopWallpaper]
    ) -> [ShopWallpaper] {

        let portraits = incoming.filter { $0.isPortrait }
        let landscapes = incoming.filter { $0.isLandscape }

        // Strategy:
        // - 2 portraits
        // - 1 landscape
        // - repeat

        var result: [ShopWallpaper] = []
        var pIndex = 0
        var lIndex = 0

        while pIndex < portraits.count || lIndex < landscapes.count {
            if pIndex < portraits.count {
                result.append(portraits[pIndex])
                pIndex += 1
            }
            if pIndex < portraits.count {
                result.append(portraits[pIndex])
                pIndex += 1
            }
            if lIndex < landscapes.count {
                result.append(landscapes[lIndex])
                lIndex += 1
            }
        }

        return existing + result
    }

}
