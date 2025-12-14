//
//  SecureFileStore.swift
//  niramrotate
//
//  Created by aravinthan.selvaraj on 14/12/25.
//

import Foundation
import CryptoKit
import Security
import UIKit

final class SecureFileStore {

    static let shared = SecureFileStore()
    private init() {}

    // MARK: - Public API

    func saveEncrypted(_ data: Data, to url: URL) throws {
        let key = try encryptionKey()
        let sealedBox = try AES.GCM.seal(data, using: key)
        try sealedBox.combined!.write(to: url, options: .completeFileProtection)
    }
    
    func loadDecrypted(from url: URL) throws -> Data {
        let key = try encryptionKey()
        let encrypted = try Data(contentsOf: url)
        let box = try AES.GCM.SealedBox(combined: encrypted)
        return try AES.GCM.open(box, using: key)
    }

    func loadDecryptedImage(from url: URL) throws -> UIImage {
        let key = try encryptionKey()
        let encrypted = try Data(contentsOf: url)
        let box = try AES.GCM.SealedBox(combined: encrypted)
        let data = try AES.GCM.open(box, using: key)

        guard let image = UIImage(data: data) else {
            throw NSError(domain: "InvalidImage", code: -1)
        }

        return image
    }

    // MARK: - Key Derivation

    private func encryptionKey() throws -> SymmetricKey {
        let privateKey = try KeyStore.getOrCreateKey()
        var error: Unmanaged<CFError>?

        guard
            let publicKey = SecKeyCopyPublicKey(privateKey),
            let publicKeyData = SecKeyCopyExternalRepresentation(publicKey, &error) as Data?
        else {
            throw error!.takeRetainedValue()
        }

        let hash = SHA256.hash(data: publicKeyData)
        return SymmetricKey(data: hash)
    }
    
}
