//
//  WallhavenAPI.swift
//  niramrotate
//
//  Created by aravinthan.selvaraj on 16/12/25.
//

import Foundation

enum WallhavenAPI {

    static let baseURL = "https://wallhaven.cc/api/v1/search"
    
    static func fetch(
        filters: ShopFilters,
        page: Int
    ) async throws -> [ShopWallpaper] {
        if filters.wantsMixedRatios {
            async let portrait = fetchSingleRatio(
                filters: filters,
                ratio: "9x16",
                page: page
            )

            async let landscape = fetchSingleRatio(
                filters: filters,
                ratio: "16x9",
                page: page
            )

            let (p, l) = try await (portrait, landscape)
            return p + l
        } else {
            let ratio = filters.aspectRatios.first?.rawValue
            return try await fetchSingleRatio(
                filters: filters,
                ratio: ratio,
                page: page
            )
        }

//        let components = buildQuery(from: filters, page: page)
//
//        let (data, _) = try await URLSession.shared.data(from: components.url!)
//        let response = try JSONDecoder().decode(Response.self, from: data)
//        
//        return response.data.map {
//            let parts = $0.resolution.split(separator: "x")
//            return ShopWallpaper(
//                id: $0.id,
//                previewURL: URL(string: $0.thumbs.small)!,
//                fullURL: URL(string: $0.path)!,
//                width: Int(parts.first ?? "0") ?? 0,
//                height: Int(parts.last ?? "0") ?? 0,
//                purity: $0.purity
//            )
//        }
    }
    
    static func fetchSingleRatio(
        filters: ShopFilters,
        ratio: String?,
        page: Int
    ) async throws -> [ShopWallpaper] {

        var components = await buildQuery(from: filters, page: page)

        if let ratio {
            components.queryItems?.removeAll { $0.name == "ratios" }
            components.queryItems?.append(
                URLQueryItem(name: "ratios", value: ratio)
            )
        }

        let (data, _) = try await URLSession.shared.data(from: components.url!)
        let response = try JSONDecoder().decode(Response.self, from: data)

        return response.data.map {
            let parts = $0.resolution.split(separator: "x")
            return ShopWallpaper(
                id: $0.id,
                previewURL: URL(string: $0.thumbs.small)!,
                fullURL: URL(string: $0.path)!,
                webURL:  URL(string: $0.url)!,
                views: $0.views,
                favorites: $0.favorites,
                purity: $0.purity,
                category: $0.category,
                width: Int(parts[0]) ?? 0,
                height: Int(parts[1]) ?? 0,
                ratio: $0.ratio,
                fileSize: $0.file_size,
                fileType: $0.file_type,
                createdAt: $0.created_at
            )
        }
    }

    static func buildQuery(
        from filters: ShopFilters,
        page: Int
    ) async -> URLComponents {

        var components = URLComponents(string: baseURL)!
        var items: [URLQueryItem] = []
        
        if let key = try? await WallhavenKeyStore.loadWithBiometrics() {
            items.append(.init(name: "apikey", value: key))
        }

        // Search
        if !filters.query.trimmingCharacters(in: .whitespaces).isEmpty {
            items.append(.init(name: "q", value: filters.query))
            items.append(.init(name: "sorting", value: "relevance"))
        } else {
            items.append(.init(name: "sorting", value: filters.sorting.rawValue))
        }

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
        
        // Ratios
//        if !filters.aspectRatios.isEmpty {
//            items.append(.init(
//                name: "ratios",
//                value: filters.aspectRatios.map { $0.rawValue }.joined(separator: ",")
//            ))
//        }
        if !filters.aspectRatios.isEmpty {
            let ratios = filters.aspectRatios
                    .map { $0.rawValue }
                    .joined(separator: ",")
            print("Ratios: ", ratios)
            items.append(
                URLQueryItem(
                    name: "ratios",
                    value: ratios
                )
            )
        }


        items.append(.init(name: "page", value: "\(page)"))

        components.queryItems = items

        if let url = components.url {
            let request = URLRequest(url: url)
//            print("RAW REQUEST URL:", request.url?.absoluteString ?? "nil")
//            print("PERCENT ENCODED URL:", components.percentEncodedQuery ?? "")
        }

        print("🔍 WALLHAVEN QUERY:", components.url?.absoluteString ?? "nil")
        return components
    }
}

// MARK: - Response Models

private struct Response: Decodable {
    let data: [Item]
}

private struct Item: Decodable {
    let id: String
    let path: String
    let resolution: String
    let purity: String
    let thumbs: Thumbs
    let ratio: String
    
    let views: Int
    let favorites: Int
    let category: String
    let dimension_x: Int
    let dimension_y: Int
    let file_size: Int
    let file_type: String
    let created_at: String
    let url: String

    struct Thumbs: Decodable {
        let small: String
    }
}
