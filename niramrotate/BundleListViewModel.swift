//
//  BundleListViewModel.swift
//  niramrotate
//
//  Created by aravinthan.selvaraj on 14/12/25.
//

import Foundation
import Combine

final class BundleListViewModel: ObservableObject {
    @Published var bundles: [ImageBundle] = []

    func load() {
        bundles = ImageBundleStore.shared.loadAllBundles()
        let bundles = ImageBundleStore.shared.loadAllBundles()

        if let first = bundles.first {
            let images = ImageBundleStore.shared.listEncryptedImages(forID: first.id)
            if let url = images.first {
                let img = try? SecureFileStore.shared.loadDecrypted(from: url)
                print("Decrypted image:", img != nil)
            }
        }

    }
}
