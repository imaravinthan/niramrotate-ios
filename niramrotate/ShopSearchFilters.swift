//
//  ShopSearchFilters.swift
//  niramrotate
//
//  Created by aravinthan.selvaraj on 16/12/25.
//

import Foundation

struct ShopSearchFilters: Equatable {
    var query: String = ""
    var showNSFW: Bool = false
    var showAnime: Bool = false

    // Future-ready (not wired yet)
    var ratios: [String] = ["9x16"]
    var atleast: String = "1170x2532"
}
