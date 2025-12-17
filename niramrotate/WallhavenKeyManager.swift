//
//  WallhavenKeyManager.swift
//  niramrotate
//
//  Created by aravinthan.selvaraj on 17/12/25.
//


import Foundation
import Combine

@MainActor
final class WallhavenKeyManager: ObservableObject {

    static let shared = WallhavenKeyManager()

    @Published private(set) var hasKey = false
    @Published private(set) var maskedKey: String = ""

    private init() {
        Task { await refresh() }
    }

    func refresh() async {
        if let key = try? await WallhavenKeyStore.loadWithBiometrics() {
            hasKey = true
            maskedKey = String(repeating: "•", count: max(6, key.count))
        } else {
            hasKey = false
            maskedKey = ""
        }
    }

    func save(_ key: String) async throws {
        try await WallhavenKeyStore.save(key)
        await refresh()
    }

    func delete() async throws {
        try await WallhavenKeyStore.delete()
        await refresh()
    }

    func revealWithBiometrics() async throws -> String {
        try await WallhavenKeyStore.loadWithBiometrics()
    }
}
