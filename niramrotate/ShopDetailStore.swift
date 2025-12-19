//
//  ShopDetailStore.swift
//  niramrotate
//
//  Created by aravinthan.selvaraj on 19/12/25.
//

import Combine
import Foundation

@MainActor
final class ShopDetailStore: ObservableObject {

    static let shared = ShopDetailStore()

    @Published private(set) var details: [String: ShopWallpaperDetails] = [:]

    func details(for id: String) -> ShopWallpaperDetails? {
        details[id]
    }

    func save(_ detail: ShopWallpaperDetails) {
        details[detail.id] = detail
    }

    func clear() {
        details.removeAll()
    }
}
