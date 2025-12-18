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

    @Published private(set) var hasKey: Bool = false
    private var cachedKey: String?
    static let shared = WallhavenKeyManager()
    init() {
        Task { await loadSilently() }
    }

    func loadSilently() async {
        cachedKey = try? KeychainHelper.load(
            service: "wallhaven_api",
            account: "default"
        )
        hasKey = cachedKey != nil
    }

    var maskedKey: String? {
        guard let key = cachedKey else { return nil }
        return String(repeating: "•", count: max(0, key.count - 4)) + key.suffix(4)
    }

    func revealKey() async throws -> String {
        try await BiometricHelper.authenticate()
        guard let key = cachedKey else { throw NSError() }
        return key
    }

    func saveKey(_ newKey: String) async throws {
        try await BiometricHelper.authenticate()
        try KeychainHelper.save(
            newKey,
            service: "wallhaven_api",
            account: "default"
        )
        cachedKey = newKey
        hasKey = true
    }

    func clear() {
        KeychainHelper.delete(service: "wallhaven_api", account: "default")
        cachedKey = nil
        hasKey = false
    }
}
