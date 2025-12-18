//
//  MockPreview.swift
//  niramrotate
//
//  Created by aravinthan.selvaraj on 18/12/25.
//
import SwiftUI
import Foundation

#if DEBUG
extension ShopWallpaper {

    static let previewPortrait = ShopWallpaper(
        id: "preview_portrait",
        previewURL: URL(string: "https://picsum.photos/400/800")!,
        fullURL: URL(string: "https://picsum.photos/400/800")!,
        webURL: URL(string: "https://example.com")!,
        views: 1245,
        favorites: 87,
        purity: "sfw",
        category: "general",
        width: 1080,
        height: 1920,
        ratio: "9x16",
        fileSize: 1_450_000,
        fileType: "image/jpeg",
        createdAt: "2025-01-01"
    )

    static let previewLandscape = ShopWallpaper(
        id: "preview_landscape",
        previewURL: URL(string: "https://picsum.photos/800/400")!,
        fullURL: URL(string: "https://picsum.photos/800/400")!,
        webURL: URL(string: "https://example.com")!,
        views: 980,
        favorites: 42,
        purity: "sfw",
        category: "general",
        width: 1920,
        height: 1080,
        ratio: "16x9",
        fileSize: 2_300_000,
        fileType: "image/jpeg",
        createdAt: "2025-01-01"
    )

    static let previewNSFW = ShopWallpaper(
        id: "preview_nsfw",
        previewURL: URL(string: "https://picsum.photos/401/801")!,
        fullURL: URL(string: "https://picsum.photos/401/801")!,
        webURL: URL(string: "https://example.com")!,
        views: 666,
        favorites: 13,
        purity: "nsfw",
        category: "people",
        width: 1080,
        height: 1920,
        ratio: "9x16",
        fileSize: 1_900_000,
        fileType: "image/jpeg",
        createdAt: "2025-01-01"
    )
}
#endif
