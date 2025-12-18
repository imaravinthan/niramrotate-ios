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
    @Published private(set) var maskedKey: String?

    private let keychainKey = "wallhaven_api_key"

    private init() {
        // ❌ NO BIOMETRICS HERE
        // silent check only
        if let key = try? KeychainHelper.load(service: keychainKey, account: "default") {
            hasKey = true
            maskedKey = mask(key)
        }
    }

    func revealKey() async throws -> String {
        try await BiometricHelper.authenticate()
        let key = try KeychainHelper.load(service: keychainKey, account: "default")
        return key
    }

    func saveKey(_ key: String) async throws {
        try await BiometricHelper.authenticate()
        try KeychainHelper.save(key, service: keychainKey, account: "default")
        hasKey = true
        maskedKey = mask(key)
    }

    func deleteKey() throws {
        try KeychainHelper.delete(service: keychainKey, account: "default")
        hasKey = false
        maskedKey = nil
    }

    private func mask(_ key: String) -> String {
        let prefix = key.prefix(4)
        let suffix = key.suffix(2)
        return "\(prefix)••••••\(suffix)"
    }
}
