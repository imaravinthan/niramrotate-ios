//
//  WallhavenAPI.swift
//  niramrotate
//
//  Created by aravinthan.selvaraj on 16/12/25.
//

import Foundation

enum WallhavenAPI {

    // MARK: - Endpoints

    private static let searchURL = "https://wallhaven.cc/api/v1/search"
    private static let detailURL = "https://wallhaven.cc/api/v1/w"

    // MARK: - Public Models

    struct PageResult {
        let items: [ShopWallpaper]
        let currentPage: Int
        let lastPage: Int
    }

    // MARK: - SEARCH (ALWAYS USED)

    static func search(
        filters: ShopFilters,
        page: Int
    ) async throws -> PageResult {

        var components = URLComponents(string: searchURL)!
        var items: [URLQueryItem] = []

        // Search query
        if !filters.query.isEmpty {
            items.append(.init(name: "q", value: filters.query))
            items.append(.init(name: "sorting", value: "relevance"))
        } else {
            items.append(.init(name: "sorting", value: filters.sorting.rawValue))
        }

        // Categories & purity
        items.append(.init(name: "categories", value: filters.categoryMask()))
        items.append(.init(name: "purity", value: filters.purityMask()))

        // Ratios
        if !filters.aspectRatios.isEmpty {
            items.append(
                .init(
                    name: "ratios",
                    value: filters.aspectRatios.map(\.rawValue).joined(separator: ",")
                )
            )
        }

        items.append(.init(name: "page", value: "\(page)"))
        components.queryItems = items

        let (data, _) = try await URLSession.shared.data(from: components.url!)
        let response = try JSONDecoder().decode(SearchResponse.self, from: data)

        let wallpapers = response.data.map { $0.toWallpaper() }

        return PageResult(
            items: wallpapers,
            currentPage: response.meta.current_page,
            lastPage: response.meta.last_page
        )
    }

    // MARK: - DETAILS (API KEY REQUIRED)

    static func fetchDetails(
        id: String,
        apiKey: String
    ) async throws -> ShopWallpaperDetails {

        let url = URL(string: "\(detailURL)/\(id)?apikey=\(apiKey)")!
        let (data, _) = try await URLSession.shared.data(from: url)

        let response = try JSONDecoder().decode(DetailResponse.self, from: data)
        return response.data.toDetails()
    }

}

private struct SearchResponse: Decodable {
    let data: [SearchItem]
    let meta: Meta
}

private struct Meta: Decodable {
    let current_page: Int
    let last_page: Int
    let total: Int
    let per_page: Int
}

struct ShopTag: Identifiable, Hashable {

    let id: Int
    let name: String
    let category: String
    let purity: String
}
struct ShopWallpaperDetails: Identifiable {

    let id: String

    // MARK: - Uploader
    let uploaderName: String
    let uploaderAvatarURL: URL?

    // MARK: - Meta
    let tags: [ShopTag]
    let source: String?
}

private struct SearchItem: Decodable {
    let id: String
    let path: String
    let thumbs: Thumbs
    let resolution: String
    let purity: String
    let category: String
    let ratio: String
    let views: Int
    let favorites: Int
    let file_size: Int
    let file_type: String
    let created_at: String
    let url: String

    struct Thumbs: Decodable {
        let small: String
    }

    func toWallpaper() -> ShopWallpaper {
        let parts = resolution.split(separator: "x")
        return ShopWallpaper(
            id: id,
            previewURL: URL(string: thumbs.small)!,
            fullURL: URL(string: path)!,
            webURL: URL(string: url)!,
            views: views,
            favorites: favorites,
            purity: purity,
            category: category,
            width: Int(parts[0]) ?? 0,
            height: Int(parts[1]) ?? 0,
            ratio: ratio,
            fileSize: file_size,
            fileType: file_type,
            createdAt: created_at
        )
    }
}

private struct DetailResponse: Decodable {
    let data: DetailItem
}

private struct DetailItem: Decodable {

    let id: String
    let source: String
    let uploader: Uploader
    let tags: [Tag]

    struct Uploader: Decodable {
        let username: String
        let avatar: Avatar?
    }

    struct Avatar: Decodable {
        let small: String?
    }

    struct Tag: Decodable {
        let id: Int
        let name: String
        let category: String
        let purity: String
    }

    func toDetails() -> ShopWallpaperDetails {
        ShopWallpaperDetails(
            id: id,
            uploaderName: uploader.username,
            uploaderAvatarURL: uploader.avatar?.small.flatMap(URL.init),
            tags: tags.map {
                ShopTag(
                    id: $0.id,
                    name: $0.name,
                    category: $0.category,
                    purity: $0.purity
                )
            },
            source: source.isEmpty ? nil : source
        )
    }
}
