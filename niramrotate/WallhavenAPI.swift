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
        preferences: ShopPreferences
    ) async throws -> [ShopWallpaper] {

        var components = URLComponents(string: baseURL)!
        components.queryItems = [
            .init(name: "atleast", value: "1170x2532"),
            .init(name: "sorting", value: "date_added"),
            .init(name: "order", value: "desc"),
            .init(name: "page", value: "\(page)"),
            .init(name: "categories", value: preferences.showAnime ? "110" : "100"),
            .init(name: "purity", value: preferences.showNSFW ? "111" : "100"),
            .init(name: "q", value: "portrait")
        ]


        let url = components.url!
        let (data, _) = try await URLSession.shared.data(from: url)

        let response = try JSONDecoder().decode(WallhavenResponse.self, from: data)

        return response.data.compactMap { item in
            let parts = item.resolution.split(separator: "x")
            guard
                parts.count == 2,
                let w = Int(parts[0]),
                let h = Int(parts[1]),
                h > w        // 🔑 PORTRAIT ONLY
            else { return nil }

            return ShopWallpaper(
                id: item.id,
                previewURL: URL(string: item.thumbs.small)!,
                fullURL: URL(string: item.path)!,
                width: w,
                height: h,
                isNSFW: item.purity != "sfw"
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
