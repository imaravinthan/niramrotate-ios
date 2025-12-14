//
//  WallpaperService.swift
//  niramrotate
//
//  Created by aravinthan.selvaraj on 14/12/25.
//

import UIKit

enum WallpaperService {

    static func setRandomWallpaper(bundleName: String) throws {

        // 1. Load bundle
        guard let bundle = ImageBundleStore.shared
            .loadAllBundles()
            .first(where: { $0.name == bundleName })
        else {
            throw NSError(domain: "BundleNotFound", code: 1)
        }

        // 2. Get random decrypted image
        guard let image = ImageBundleStore.shared
            .loadRandomDecryptedImage(forID: bundle.id)
        else {
            throw NSError(domain: "ImageNotFound", code: 2)
        }

        // 3. Set wallpaper (Home + Lock)
        try WallpaperSetter.apply(image)
    }
}
