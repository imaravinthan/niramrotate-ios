//
//  WallpaperSetter.swift
//  niramrotate
//
//  Created by aravinthan.selvaraj on 14/12/25.
//

import UIKit

enum WallpaperSetter {

    static func apply(_ image: UIImage) throws {
        let data = image.jpegData(compressionQuality: 1.0)!
        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("wallpaper.jpg")

        try data.write(to: tempURL, options: .atomic)

        // iOS uses this URL via Shortcuts
        // We don't call private APIs here
        // Shortcuts will handle the actual wallpaper change
    }
}
