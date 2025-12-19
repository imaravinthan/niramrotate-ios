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

#if DEBUG
extension ShopWallpaper {

    static let previewAPIKEY = ShopWallpaper(
        id: "2y8316",
        previewURL: URL(string: "https://picsum.photos/401/801")!,
        fullURL: URL(string: "https://picsum.photos/401/801")!,
        webURL: URL(string: "https://wallhaven.cc/w/2y8316")!,
        views: 1048,
        favorites: 87,
        purity: "nsfw",
        category: "people",
        width: 1080,
        height: 1920,
        ratio: "9x16",
        fileSize: 1_900_000,
        fileType: "image/jpeg",
        createdAt: "2025-01-01",

        // 🔑 API-KEY ONLY FIELDS
        uploader: "Uer1",
        tags: [
            ShopTag(
                id: 109,
                name: "photography",
                category: "Photography",
                purity: "sfw"
            ),
            ShopTag(
                id: 37,
                name: "nature",
                category: "Nature",
                purity: "sfw"
            ),
            ShopTag(
                id: 1722,
                name: "plants",
                category: "Plants",
                purity: "sfw"
            ),
            ShopTag(
                id: 1362,
                name: "building",
                category: "Architecture",
                purity: "sfw"
            ),
            ShopTag(
                id: 32459,
                name: "portrait display",
                category: "Digital",
                purity: "sfw"
            )
        ]
    )
}
#endif

