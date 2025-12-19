//
//  ShopPreferences.swift
//  niramrotate
//
//  Created by aravinthan.selvaraj on 16/12/25.
//
import Foundation
import Combine

@MainActor
final class ShopPreferences: ObservableObject {

    static let shared = ShopPreferences()

    @Published private(set) var hasWallhavenKey = false
//    @Published var revealedKey: String?
    private var cancellable: AnyCancellable?

    private init() {
        let manager = WallhavenKeyManager.shared
        hasWallhavenKey = manager.hasKey

        cancellable = manager.$hasKey
            .receive(on: RunLoop.main)
            .assign(to: \.hasWallhavenKey, on: self)
    }

    private let historyKey = "shop_seen_ids"

    // MARK: - Seen

    func hasSeen(_ id: String) -> Bool {
        let set = Set(UserDefaults.standard.stringArray(forKey: historyKey) ?? [])
        return set.contains(id)
    }

    func markSeen(_ id: String) {
        var set = Set(UserDefaults.standard.stringArray(forKey: historyKey) ?? [])
        set.insert(id)
        UserDefaults.standard.set(Array(set), forKey: historyKey)
    }

    func clearHistory() {
        UserDefaults.standard.removeObject(forKey: historyKey)
    }
    
    #if DEBUG
    func _setHasWallhavenKeyForPreview(_ value: Bool) {
        hasWallhavenKey = value
    }
    #endif

}
