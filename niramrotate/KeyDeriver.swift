//
//  KeyDeriver.swift
//  niramrotate
//
//  Created by aravinthan.selvaraj on 14/12/25.
//

import Foundation
import CryptoKit
import Security

struct KeyDeriver {

    static func deriveSymmetricKey(from privateKey: SecKey) throws -> SymmetricKey {
        var error: Unmanaged<CFError>?
        guard let publicKey = SecKeyCopyPublicKey(privateKey),
              let data = SecKeyCopyExternalRepresentation(publicKey, &error) as Data?
        else {
            throw CryptoError.encryptionFailed
        }

        let hash = SHA256.hash(data: data)
        return SymmetricKey(data: hash)
    }
}
