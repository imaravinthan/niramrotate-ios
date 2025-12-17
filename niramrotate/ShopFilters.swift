//
//  ShopFilters.swift
//  niramrotate
//
//  Created by aravinthan.selvaraj on 17/12/25.
//


import Foundation

struct ShopFilters {

    // MARK: - Search
    var query: String = ""

    // MARK: - Sorting
    enum Sorting: String, CaseIterable {
        case latest
        case hot
        case toplist
        case relevance
        case random
    }
    var sorting: Sorting = .latest

    // MARK: - Categories
    enum Category: CaseIterable {
        case general, anime, people
    }
    var categories: Set<Category> = [.general]

    // MARK: - Purity (STRICT)
    enum PurityMode {
        case sfw
        case nsfw
    }
    var purity: PurityMode = .sfw

    // MARK: - Aspect Ratios
    enum AspectRatio: String, CaseIterable {
        case portrait = "portrait"
        case landscape = "landscape"
    }
    var aspectRatios: Set<AspectRatio> = [.portrait]
    
    
    // MARK: - Preferences
    var rememberSeen: Bool = true

    // MARK: - Helpers (Wallhaven masks)

    func categoryMask() -> String {
        let g = categories.contains(.general) ? "1" : "0"
        let a = categories.contains(.anime)   ? "1" : "0"
        let p = categories.contains(.people)  ? "1" : "0"
        return g + a + p
    }

    func purityMask() -> String {
        switch purity {
        case .sfw:
            return "100"
        case .nsfw:
            return "110"   // sfw + sketchy
        }
    }
}
extension ShopFilters {
    var wantsMixedRatios: Bool {
        aspectRatios.contains(.portrait) && aspectRatios.contains(.landscape)
    }
}
