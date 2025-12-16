//
//  WallhavenAPI.swift
//  niramrotate
//
//  Created by aravinthan.selvaraj on 16/12/25.
//

import Foundation

enum WallhavenAPI {

    static let baseURL = "https://wallhaven.cc/api/v1/search"

    static func fetchWallpapers(
        page: Int,
        filters: ShopSearchFilters
    ) async throws -> [ShopWallpaper] {

        var components = URLComponents(string: baseURL)!
        var queryItems: [URLQueryItem] = []

        // Search query
        if !filters.query.isEmpty {
            queryItems.append(
                .init(name: "q", value: filters.query)
            )
        }

        // Ratios (portrait)
        queryItems.append(
            .init(name: "ratios", value: filters.ratios.joined(separator: ","))
        )

        // Minimum resolution
        queryItems.append(
            .init(name: "atleast", value: filters.atleast)
        )

        // Categories
        // General(1), Anime(2), People(4)
        let categories = filters.showAnime ? "110" : "100"
        queryItems.append(.init(name: "categories", value: categories))

        // Purity
        // SFW(1), Sketchy(2), NSFW(4)
        let purity = filters.showNSFW ? "111" : "100"
        queryItems.append(.init(name: "purity", value: purity))

        // Sorting
        queryItems.append(.init(name: "sorting", value: "date_added"))
        queryItems.append(.init(name: "order", value: "desc"))
        queryItems.append(.init(name: "page", value: "\(page)"))

        components.queryItems = queryItems

        let (data, _) = try await URLSession.shared.data(from: components.url!)
        let decoded = try JSONDecoder().decode(WallhavenResponse.self, from: data)

        return decoded.data.map {
            let parts = $0.resolution.split(separator: "x")
            let w = Int(parts.first ?? "0") ?? 0
            let h = Int(parts.last ?? "0") ?? 0

            return ShopWallpaper(
                id: $0.id,
                previewURL: URL(string: $0.thumbs.small)!,
                fullURL: URL(string: $0.path)!,
                width: w,
                height: h,
                isNSFW: $0.purity != "sfw"
            )
        }
    }
}


struct WallhavenResponse: Decodable {
    let data: [WallhavenItem]
}

struct WallhavenItem: Decodable {
    let id: String
    let path: String
    let resolution: String
    let purity: String
    let thumbs: Thumbs

    struct Thumbs: Decodable {
        let small: String
    }
}
