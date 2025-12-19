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

    @Published private(set) var hasKey: Bool = false
    private var cachedKey: String?

    private let service = "wallhaven_api_key"
    private let account = "default"

    private init() {
        Task { await loadSilently() }
    }

    func loadSilently() async {
        cachedKey = try? KeychainHelper.load(
            service: service,
            account: account
        )
        hasKey = cachedKey != nil
        print("🔑 Key loaded:", cachedKey != nil)
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
            service: service,
            account: account
        )
        cachedKey = newKey
        hasKey = true
    }

    func clear() {
        KeychainHelper.delete(service: service, account: account)
        cachedKey = nil
        hasKey = false
    }

    /// Internal use (API calls)
    func getKeySilently() -> String? {
        cachedKey
    }
}
