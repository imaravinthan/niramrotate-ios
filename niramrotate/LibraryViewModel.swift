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
    @Published var selectedIDs: Set<ImageBundle.ID> = []
    @Published var showArchived = false

    
    var isAllSelected: Bool {
            !bundles.isEmpty && selectedIDs.count == bundles.count
        }
    
    var active: [ImageBundle] {
            bundles.filter { !$0.isArchived }
        }

    var archived: [ImageBundle] {
        bundles.filter { $0.isArchived }
    }
    
    func loadBundles() {
        bundles = ImageBundleStore.shared.loadAllBundles()
        applySort()
    }
//    func loadBundles() {
//        bundles = ImageBundleStore.shared
//            .loadAllBundles()
//            .filter { !$0.isArchived }
//    }


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
    
    func toggleSelectAll() {
            if isAllSelected {
                selectedIDs.removeAll()
            } else {
                selectedIDs = Set(bundles.map { $0.id })
            }
        }
    
//    func archive(_ bundle: ImageBundle) {
//        var updated = bundle
//        updated.isArchived = true
//        try? ImageBundleStore.shared.updateBundle(updated)
//        loadBundles()
//    }
//    
//    func unarchive(_ bundle: ImageBundle) {
//            var updated = bundle
//            updated.isArchived = false
//            try? ImageBundleStore.shared.updateBundle(updated)
//            loadBundles()
//    }
    
    func archive(_ bundle: ImageBundle) {
            update(bundle) { $0.isArchived = true }
        }

        func unarchive(_ bundle: ImageBundle) {
            update(bundle) { $0.isArchived = false }
        }

    func delete(_ bundle: ImageBundle) {
        try? ImageBundleStore.shared.delete(bundle)
        loadBundles()
    }

    func download(_ bundle: ImageBundle) {
        BundleExporter.export(bundle)
    }

    private func update(
            _ bundle: ImageBundle,
            change: (inout ImageBundle) -> Void
        ) {
            do {
                var updated = bundle
                change(&updated)
                try ImageBundleStore.shared.update(updated)
                loadBundles()
            } catch {
                print("❌ Update failed:", error)
            }
        }
}
