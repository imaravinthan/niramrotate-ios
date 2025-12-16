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
    @Published var isLoading = false

    private var page = 1
    private var preferences: ShopPreferences

    init(preferences: ShopPreferences = .shared) {
        self.preferences = preferences

        preferences.$showNSFW
            .merge(with: preferences.$showAnime)
            .sink { [weak self] _ in
                Task { await self?.reload() }
            }
            .store(in: &cancellables)
    }

    private var cancellables = Set<AnyCancellable>()

    func reload() async {
        page = 1
        wallpapers.removeAll()
        await loadNextPage()
    }

    func loadNextPage() async {
        guard !isLoading else { return }
        isLoading = true

        do {
            let fetched = try await WallhavenAPI.fetchWallpapers(
                page: page,
                preferences: preferences
            )

            let filtered = fetched.filter {
                $0.height > $0.width // 🔑 portrait only
            }

            wallpapers.append(contentsOf: filtered)
            page += 1
        } catch {
            print("❌ Shop fetch failed:", error)
        }

        isLoading = false
    }
}
