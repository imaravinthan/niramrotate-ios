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
    @Published var selectedIDs: Set<ImageBundle.ID> = []
    @Published var isSelectionMode = false
    @Published var sortOption: LibrarySortOption = .newest

    var active: [ImageBundle] {
        bundles.filter { !$0.isArchived }
    }

    var archived: [ImageBundle] {
        bundles.filter { $0.isArchived }
    }

    var selectedBundles: [ImageBundle] {
        bundles.filter { selectedIDs.contains($0.id) }
    }

    // MARK: - Load
    func loadBundles() {
        bundles = ImageBundleStore.shared.loadAllBundles()
        applySort()
    }

    var visibleBundles: [ImageBundle] {
        bundles.filter { bundle in
            if bundle.isNSFW && !AppSettings.shared.showNSFWEnabled {
                return false
            }
            return !bundle.isArchived
        }
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

    // MARK: - Single actions
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

    // MARK: - Selection
    func toggleSelection(_ bundle: ImageBundle) {
        if selectedIDs.contains(bundle.id) {
            selectedIDs.remove(bundle.id)
        } else {
            selectedIDs.insert(bundle.id)
        }
    }

    func clearSelection() {
        selectedIDs.removeAll()
        isSelectionMode = false
    }

    // MARK: - Bulk
    func bulkArchive() {
        selectedBundles.forEach {
            update($0) { $0.isArchived = true }
        }
        clearSelection()
    }

    func bulkDelete() {
        selectedBundles.forEach {
            try? ImageBundleStore.shared.delete($0)
        }
        loadBundles()
        clearSelection()
    }

    func bulkDownload() {
        selectedBundles.forEach(BundleExporter.export)
        clearSelection()
    }

    // MARK: - Update helper
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
            print("Update failed:", error)
        }
    }
}
