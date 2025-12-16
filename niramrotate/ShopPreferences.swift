//
//  ShopPreferences.swift
//  niramrotate
//
//  Created by aravinthan.selvaraj on 16/12/25.
//
import SwiftUI
import Combine

final class ShopPreferences: ObservableObject {

    static let shared = ShopPreferences()

    @Published var showNSFW: Bool {
        didSet { UserDefaults.standard.set(showNSFW, forKey: "shop_nsfw") }
    }

    @Published var showAnime: Bool {
        didSet { UserDefaults.standard.set(showAnime, forKey: "shop_anime") }
    }

    private let seenKey = "shop_seen_ids"

    private init() {
        self.showNSFW = UserDefaults.standard.bool(forKey: "shop_nsfw")
        self.showAnime = UserDefaults.standard.bool(forKey: "shop_anime")
    }

    func markSeen(_ id: String) {
        var set = Set(UserDefaults.standard.stringArray(forKey: seenKey) ?? [])
        set.insert(id)
        UserDefaults.standard.set(Array(set), forKey: seenKey)
    }

    func hasSeen(_ id: String) -> Bool {
        let set = Set(UserDefaults.standard.stringArray(forKey: seenKey) ?? [])
        return set.contains(id)
    }
}
