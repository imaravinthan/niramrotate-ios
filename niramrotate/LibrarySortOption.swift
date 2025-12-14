//
//  LibrarySortOption.swift
//  niramrotate
//
//  Created by aravinthan.selvaraj on 14/12/25.
//

import Foundation

enum LibrarySortOption: String, CaseIterable {
    case newest = "Newest"
    case nameAZ = "Name (A–Z)"
    case nameZA = "Name (Z–A)"
    case mostImages = "Most Images"

    func sort(_ bundles: [ImageBundle]) -> [ImageBundle] {
        switch self {
        case .newest:
            return bundles.sorted { $0.createdAt > $1.createdAt }
        case .nameAZ:
            return bundles.sorted { $0.name < $1.name }
        case .nameZA:
            return bundles.sorted { $0.name > $1.name }
        case .mostImages:
            return bundles.sorted { $0.imageCount > $1.imageCount }
        }
    }
}
