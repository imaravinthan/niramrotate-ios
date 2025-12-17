//
//  WallhavenKeyStore.swift
//  niramrotate
//
//  Created by aravinthan.selvaraj on 17/12/25.
//

import Foundation
import LocalAuthentication

enum WallhavenKeyStore {
    private static let account = "com.mavsuzhal.niramrotate"
    private static let keychainKey = "wallhaven_api_key"

    static func save(_ key: String) throws {
        try KeychainHelper.save(key, service: keychainKey, account: account)
    }

    static func loadSilently() -> String? {
        try? KeychainHelper.load(service: keychainKey, account: account)
    }

    static func loadWithBiometrics() async throws -> String {
        try await BiometricHelper.authenticate()
        return try KeychainHelper.load(service: keychainKey, account: account )
    }

    static func delete() {
        KeychainHelper.delete(service: keychainKey, account: account)
    }
}
