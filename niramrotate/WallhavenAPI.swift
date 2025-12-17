//
//  WallhavenAPI.swift
//  niramrotate
//
//  Created by aravinthan.selvaraj on 16/12/25.
//

import Foundation

enum WallhavenAPI {
    static let baseURL = "https://wallhaven.cc/api/v1/search"

    static func fetch(filters: ShopFilters, page: Int) async throws -> [ShopWallpaper] {
        let components = buildQuery(from: filters, page: page)
        let (data, _) = try await URLSession.shared.data(from: components.url!)
        let response = try JSONDecoder().decode(Response.self, from: data)
        let filtered = response.data.filter { item in
            switch item.purity {
            case "sfw":
                return filters.purity.contains(.sfw)
            case "sketchy":
                return filters.purity.contains(.sketchy)
            case "nsfw":
                return filters.purity.contains(.nsfw)
            default:
                return false
            }
        }

        return filtered.map {
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

    static func buildQuery(from filters: ShopFilters, page: Int) -> URLComponents {
        var components = URLComponents(string: baseURL)!
        var items: [URLQueryItem] = []

        // Search query
        if !filters.query.isEmpty {
            items.append(.init(name: "q", value: filters.query))
        }

        // Sorting
//        items.append(.init(name: "sorting", value: filters.sorting.rawValue))
        let sortingValue =
            filters.query.isEmpty
            ? filters.sorting.rawValue
            : "relevance"

        items.append(.init(name: "sorting", value: sortingValue))

        items.append(.init(name: "page", value: "\(page)"))
        
        // Categories
        items.append(.init(
            name: "categories",
            value: filters.categoryMask()
        ))
        
        // Purity
        items.append(.init(
            name: "purity",
            value: filters.purityMask()
        ))

        // Aspect ratios
        if !filters.aspectRatios.isEmpty {
            items.append(.init(
                name: "ratios",
                value: filters.aspectRatios.joined(separator: ",")
            ))
        }

        // Resolution
        if !filters.resolutions.isEmpty {
            items.append(.init(
                name: "atleast",
                value: filters.resolutions.first
            ))
        }

        items.append(.init(name: "page", value: "\(page)"))

        components.queryItems = items
        print("🔍 WALLHAVEN QUERY:", components.url?.absoluteString ?? "nil")
        return components
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
