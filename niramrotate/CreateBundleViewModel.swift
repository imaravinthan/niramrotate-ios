//
//  CreateBundleViewModel.swift
//  niramrotate
//
//  Created by aravinthan.selvaraj on 14/12/25.
//

import SwiftUI
import PhotosUI
import Combine

struct PreviewItem: Identifiable, Equatable {
    let id: UUID
    let image: UIImage
    let data: Data
}

@MainActor
final class CreateBundleViewModel: ObservableObject {

    // MARK: - Input
    @Published var bundleName: String = ""
    @Published var selectedItems: [PhotosPickerItem] = []

    // MARK: - Preview State (SINGLE SOURCE OF TRUTH)
    @Published private(set) var previews: [PreviewItem] = []

    // MARK: - UI State
    @Published private(set) var isCreating = false
    @Published var showResultAlert = false
    @Published var resultMessage = ""
    @Published var creationSucceeded = false

    var canCreate: Bool {
        !bundleName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !previews.isEmpty &&
        !isCreating
    }

    // MARK: - Image Picker Handling

    func appendPickedItems() async {
        for item in selectedItems {
            guard
                let data = try? await item.loadTransferable(type: Data.self),
                let image = UIImage(data: data)
            else { continue }

            let preview = PreviewItem(
                id: UUID(),
                image: image,
                data: data
            )

            previews.append(preview)
        }

        selectedItems.removeAll()
    }

    // MARK: - Remove / Clear

    func removeImage(id: UUID) {
        previews.removeAll { $0.id == id }
    }

    func clearAll() {
        previews.removeAll()
        selectedItems.removeAll()
        bundleName = ""
    }

    // MARK: - Create Bundle

    func createBundle() async {
        guard canCreate else { return }

        isCreating = true

        do {
            let bundle = try ImageBundleStore.shared.createBundle(name: bundleName)

            for item in previews {
                try ImageBundleStore.shared.addEncryptedImage(item.data, to: bundle)
            }

            creationSucceeded = true
            resultMessage = "Bundle \"\(bundleName)\" created successfully"
            showResultAlert = true

        } catch {
            creationSucceeded = false
            resultMessage = "Failed to create bundle"
            showResultAlert = true
        }

        isCreating = false
    }
}

