//
//  WallhavenAPI.swift
//  niramrotate
//
//  Created by aravinthan.selvaraj on 16/12/25.
//

import Foundation

enum WallhavenAPI {

    static func fetch(
        page: Int,
        filters: ShopSearchFilters
    ) async throws -> [ShopWallpaper] {

        var components = URLComponents(string: "https://wallhaven.cc/api/v1/search")!

        var items: [URLQueryItem] = [
            .init(name: "ratios", value: "9x16"),
            .init(name: "atleast", value: "1170x2532"),
            .init(name: "sorting", value: "date_added"),
            .init(name: "order", value: "desc"),
            .init(name: "page", value: "\(page)")
        ]

        // Categories: General + People
        items.append(
            .init(
                name: "categories",
                value: filters.showAnime ? "111" : "110"
            )
        )

        // Purity
        items.append(
            .init(
                name: "purity",
                value: filters.showNSFW ? "111" : "100"
            )
        )

        if !filters.query.isEmpty {
            items.append(.init(name: "q", value: filters.query))
        }

        components.queryItems = items

        let (data, _) = try await URLSession.shared.data(from: components.url!)
        let response = try JSONDecoder().decode(Response.self, from: data)

        return response.data.map {
            let parts = $0.resolution.split(separator: "x")
            return ShopWallpaper(
                id: $0.id,
                previewURL: URL(string: $0.thumbs.small)!,
                fullURL: URL(string: $0.path)!,
                width: Int(parts[0]) ?? 0,
                height: Int(parts[1]) ?? 0,
                isNSFW: $0.purity != "sfw"
            )
        }
    }
}

private struct Response: Decodable {
    let data: [Item]
}

private struct Item: Decodable {
    let id: String
    let path: String
    let resolution: String
    let purity: String
    let thumbs: Thumbs

    struct Thumbs: Decodable {
        let small: String
    }
}
