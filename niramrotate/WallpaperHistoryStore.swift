//
//  WallpaperHistoryStore.swift
//  niramrotate
//
//  Created by aravinthan.selvaraj on 14/12/25.
//

import Foundation

final class WallpaperHistoryStore {

    static let shared = WallpaperHistoryStore()
    private init() {}

    private let keyPrefix = "wallpaper.history."

    func lastUsedImage(for bundleID: UUID) -> String? {
        UserDefaults.standard.string(forKey: keyPrefix + bundleID.uuidString)
    }

    func saveLastUsedImage(_ filename: String, for bundleID: UUID) {
        UserDefaults.standard.set(filename, forKey: keyPrefix + bundleID.uuidString)
    }
}
