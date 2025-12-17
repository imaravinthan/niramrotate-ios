//
//  ShopSearchFilters.swift
//  niramrotate
//
//  Created by aravinthan.selvaraj on 16/12/25.
//
//
//import Foundation
//
//struct ShopSearchFilters {
//    var query: String = ""
//    var showNSFW: Bool = false
//    var showAnime: Bool = false
//}

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

    // MARK: - Categories (Wallhaven bitmask)
    var categories: Set<Category> = [.general]

    enum Category: CaseIterable {
        case general, anime, people
    }


    // MARK: - Purity
    var purity: Set<Purity> = [.sfw]

    enum Purity: CaseIterable {
        case sfw, sketchy, nsfw
    }


    // MARK: - Preferences
    var rememberSeen: Bool = true
    var aspectRatios: Set<String> = []     // e.g. "9x16"
    var resolutions: Set<String> = []      // e.g. "1170x2532"

    // MARK: - Thumb size (client-side only)
    enum ThumbSize {
        case small, medium, large
    }
    var thumbSize: ThumbSize = .medium
    
    func categoryMask() -> String {
        let g = categories.contains(.general) ? "1" : "0"
        let a = categories.contains(.anime)   ? "1" : "0"
        let p = categories.contains(.people)  ? "1" : "0"
        return g + a + p
    }

    func purityMask() -> String {
        let s = purity.contains(.sfw)      ? "1" : "0"
        let k = purity.contains(.sketchy)  ? "1" : "0"
        let n = purity.contains(.nsfw)     ? "1" : "0"
        return s + k + n
    }

}
