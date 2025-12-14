//
//  WallpaperManager.swift
//  niramrotate
//
//  Created by aravinthan.selvaraj on 14/12/25.
//
import UIKit

final class WallpaperManager {

    static let shared = WallpaperManager()
    private init() {}

    func nextWallpaper(for bundleID: String) throws -> Data {
        guard
            let uuid = UUID(uuidString: bundleID),
            let bundle = ImageBundleStore.shared
                .loadAllBundles()
                .first(where: { $0.id == uuid }),
            let image = ImageBundleStore.shared
                .loadRandomDecryptedImage(forID: bundle.id),
            let data = image.jpegData(compressionQuality: 1.0)
        else {
            throw NSError(domain: "Wallpaper", code: 404)
        }

        return data
    }
}
