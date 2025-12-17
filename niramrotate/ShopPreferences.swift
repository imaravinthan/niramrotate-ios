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
    
    @Published private(set) var hasKey = false
        @Published var revealedKey: String?

    private init() {
        Task { await loadKeyPresence() }
    }

    private let historyKey = "shop_seen_ids"
    
    func loadKeyPresence() async {
            let key = try? await WallhavenKeyStore.loadWithBiometrics()
            hasKey = (key != nil)
        }

        func authenticateAndRevealKey() async {
            do {
                revealedKey = try await WallhavenKeyStore.loadWithBiometrics()
            } catch {
                revealedKey = nil
            }
        }

        func saveKey(_ key: String) async throws {
            guard !key.trimmingCharacters(in: .whitespaces).isEmpty else {
                throw NSError(domain: "EmptyKey", code: 1)
            }

            try await WallhavenKeyStore.save(key)
            hasKey = true
            revealedKey = nil
        }

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

