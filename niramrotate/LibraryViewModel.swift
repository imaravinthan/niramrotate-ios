//
//  LibraryViewModel.swift
//  niramrotate
//
//  Created by aravinthan.selvaraj on 14/12/25.
//

import SwiftUI
import UIKit
import Combine

@MainActor
final class LibraryViewModel: ObservableObject {

    @Published var bundles: [ImageBundle] = []
    @Published var isGrid = true
    @Published var sortOption: LibrarySortOption = .newest

    func loadBundles() {
        bundles = ImageBundleStore.shared.loadAllBundles()
        applySort()
    }

    func applySort() {
        switch sortOption {
        case .newest:
            bundles.sort { $0.createdAt > $1.createdAt }
        case .nameAZ:
            bundles.sort { $0.name.lowercased() < $1.name.lowercased() }
        case .nameZA:
            bundles.sort { $0.name.lowercased() > $1.name.lowercased() }
        case .mostImages:
            bundles.sort { $0.imageCount > $1.imageCount }
        }
    }

//    func thumbnail(for bundle: ImageBundle) -> UIImage? {
//        ImageBundleStore.shared.loadThumbnail(for: bundle)
//    }
    
    func wallpaper(for bundle: ImageBundle) -> UIImage? {
        ImageBundleStore.shared.loadRandomDecryptedImage(forID: bundle.id)
    }


}
