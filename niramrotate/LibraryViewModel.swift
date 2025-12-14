//
//  LibraryViewModel.swift
//  niramrotate
//
//  Created by aravinthan.selvaraj on 14/12/25.
//

import Foundation
import Combine

final class LibraryViewModel: ObservableObject {
    @Published var bundles: [ImageBundle] = []
    @Published var sortOption: LibrarySortOption = .recent
    @Published var isGrid = true

    func loadBundles() {
        bundles = ImageBundleStore.shared.loadAllBundles()
        applySort()
    }

    func applySort() {
        switch sortOption {
        case .recent:
            bundles.sort { $0.createdAt > $1.createdAt }
        case .name:
            bundles.sort { $0.name < $1.name }
        case .imageCount:
            bundles.sort { $0.imageCount > $1.imageCount }
        }
    }
}
