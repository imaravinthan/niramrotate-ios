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

    // MARK: - Preview (single source of truth)
    @Published private(set) var previews: [PreviewItem] = []
    @Published var currentIndex: Int = 0

    // MARK: - UI State
    @Published private(set) var isCreating = false
    @Published var showResultAlert = false
    @Published var resultMessage = ""
    @Published var creationSucceeded = false
    @Published var isNSFW = false

    @Published var showPicker = false
    @Published var showDeleteSheet = false
    @Published var isDuplicateName = false

    private var importedItemIDs = Set<String>()
    
    private var cancellables = Set<AnyCancellable>()

    init() {
        $bundleName
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] name in
                guard let self else { return }
                let trimmed = name.trimmingCharacters(in: .whitespaces)
                self.isDuplicateName =
                    !trimmed.isEmpty &&
                    ImageBundleStore.shared.bundleExists(named: trimmed)
            }
            .store(in: &cancellables)
    }

    
    var canCreate: Bool {
        !bundleName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !previews.isEmpty &&
        !isCreating &&
        !isDuplicateName
    }


    // MARK: - Picker import (append-only)
    func appendPickedItems() async {
        for item in selectedItems {

            let identifier = item.itemIdentifier ?? UUID().uuidString
            guard !importedItemIDs.contains(identifier) else { continue }

            guard
                let data = try? await item.loadTransferable(type: Data.self),
                let image = UIImage(data: data)
            else { continue }

            previews.append(
                PreviewItem(
                    id: UUID(),
                    image: image,
                    data: data
                )
            )

            importedItemIDs.insert(identifier)
        }

        selectedItems.removeAll()
    }

    // MARK: - Deletion
    func removeCurrentImage() {
        guard !previews.isEmpty else { return }

        previews.remove(at: currentIndex)

        if currentIndex >= previews.count {
            currentIndex = max(previews.count - 1, 0)
        }
    }

    func clearAll() {
        previews.removeAll()
        selectedItems.removeAll()
        importedItemIDs.removeAll()
        currentIndex = 0
    }

    // MARK: - Create bundle
    func createBundle() async {
        guard canCreate else { return }

        isCreating = true

        do {
            let bundle = try ImageBundleStore.shared.createBundle(
                name: bundleName,
                isNSFW: isNSFW
            )

            for item in previews {
                try ImageBundleStore.shared.addEncryptedImage(item.data, to: bundle)
            }

            creationSucceeded = true
            resultMessage = "Bundle \"\(bundleName)\" created"
            showResultAlert = true

            clearAll()
            bundleName = ""

        } catch {
            creationSucceeded = false
            resultMessage = "Failed to create bundle"
            showResultAlert = true
        }

        isCreating = false
    }
}
