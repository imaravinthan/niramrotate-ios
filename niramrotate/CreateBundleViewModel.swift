//
//  CreateBundleViewModel.swift
//  niramrotate
//
//  Created by aravinthan.selvaraj on 14/12/25.
//

import SwiftUI
import PhotosUI
import Combine

@MainActor
final class CreateBundleViewModel: ObservableObject {

    // MARK: - Input
    @Published var bundleName: String = ""
    @Published var selectedItems: [PhotosPickerItem] = []

    // MARK: - Derived UI State
    @Published private(set) var previewImages: [UIImage] = []
    @Published private(set) var isCreating = false
    @Published private(set) var errorMessage: String?

    // Internal storage (never touch from View)
    private var imageData: [Data] = []

    var canCreate: Bool {
        !bundleName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !imageData.isEmpty &&
        !isCreating
    }
    
    @MainActor
    func appendImage(data: Data, image: UIImage) {
        imageData.append(data)
        previewImages.append(image)
    }
    
    func appendPickedItems() async {
        for item in selectedItems {
            guard let data = try? await item.loadTransferable(type: Data.self),
                  let image = UIImage(data: data)
            else { continue }

            imageData.append(data)
            previewImages.append(image)
        }

        selectedItems.removeAll()
    }


    // MARK: - Remove / Clear
    @MainActor
    func removeImage(at index: Int) {
        guard index < imageData.count else { return }
        imageData.remove(at: index)
        previewImages.remove(at: index)
    }
    
    @MainActor
    func clearImages() {
        imageData.removeAll()
        previewImages.removeAll()
    }

    @MainActor
    func clearAll() {
        selectedItems.removeAll()
        previewImages.removeAll()
        imageData.removeAll()
        bundleName = ""
    }

    // MARK: - Create Bundle

    func createBundle() async -> Bool {
        guard canCreate else { return false }

        isCreating = true
        defer { isCreating = false }

        do {
            let bundle = try ImageBundleStore.shared.createBundle(name: bundleName)

            for data in imageData {
                try ImageBundleStore.shared.addEncryptedImage(data, to: bundle)
            }

            // Save thumbnail (first image only)
//            if let first = imageData.first {
//                try ImageBundleStore.shared.saveThumbnail(first, for: bundle)
//            }
            clearAll()
            return true

        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
}
