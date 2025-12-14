//
//  SecureFileStore.swift
//  niramrotate
//
//  Created by aravinthan.selvaraj on 14/12/25.
//

import Foundation
import CryptoKit
import Security

final class SecureFileStore {

    static let shared = SecureFileStore()

    private let baseURL: URL

    private init() {
        let fm = FileManager.default
        baseURL = fm.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        try? fm.createDirectory(at: baseURL, withIntermediateDirectories: true)
    }

    // MARK: - Public API

    func saveEncrypted(_ data: Data, filename: String) throws {
        let key = try encryptionKey()
        let sealedBox = try AES.GCM.seal(data, using: key)
        let url = baseURL.appendingPathComponent(filename)
        try sealedBox.combined!.write(to: url, options: .completeFileProtection)
    }

    func loadDecrypted(filename: String) throws -> Data {
        let key = try encryptionKey()
        let url = baseURL.appendingPathComponent(filename)
        let encrypted = try Data(contentsOf: url)
        let box = try AES.GCM.SealedBox(combined: encrypted)
        return try AES.GCM.open(box, using: key)
    }

    // MARK: - Key Derivation

    private func encryptionKey() throws -> SymmetricKey {
        let privateKey = try KeyStore.getOrCreateKey()
        var error: Unmanaged<CFError>?

        guard let publicKeyData = SecKeyCopyExternalRepresentation(
            SecKeyCopyPublicKey(privateKey)!,
            &error
        ) as Data? else {
            throw error!.takeRetainedValue()
        }

        let hash = SHA256.hash(data: publicKeyData)
        return SymmetricKey(data: hash)
    }
}
