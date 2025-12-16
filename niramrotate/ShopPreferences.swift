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
    private init() {}

    private let historyKey = "shop_seen_ids"

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
}

