//
//  WallpaperRotationEngine.swift
//  niramrotate
//
//  Created by aravinthan.selvaraj on 14/12/25.
//

import Foundation

final class WallpaperRotationEngine {

    static let shared = WallpaperRotationEngine()
    private init() {}

    func nextImageData(forID bundleID: UUID) throws -> Data {
        let images = ImageBundleStore.shared.listEncryptedImages(forID: bundleID)
        guard !images.isEmpty else {
            throw NSError(domain: "NoImages", code: 0)
        }

        let index = nextIndex(forID: bundleID, count: images.count)
        let file = images[index]

        return try SecureFileStore.shared.loadDecrypted(from: file)
    }

    private func nextIndex(forID bundleID: UUID, count: Int) -> Int {
        let key = "rotation_index_\(bundleID.uuidString)"
        let current = UserDefaults.standard.integer(forKey: key)
        let next = (current + 1) % count
        UserDefaults.standard.set(next, forKey: key)
        return current
    }

}

