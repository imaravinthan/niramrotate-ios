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
    }
}
