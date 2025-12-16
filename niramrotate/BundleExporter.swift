//
//  BundleExporter.swift
//  niramrotate
//
//  Created by aravinthan.selvaraj on 16/12/25.
//

import UIKit

enum BundleExporter {

    static func export(_ bundle: ImageBundle) {
        let temp = FileManager.default.temporaryDirectory
            .appendingPathComponent("\(bundle.name).zip")

        // TODO: zip encrypted images (next iteration)
        // For now: export raw folder

        let source = ImageBundleStore.shared.bundleURL(for: bundle)

        let controller = UIDocumentPickerViewController(
            forExporting: [source]
        )

        UIApplication.shared
            .topViewController?
            .present(controller, animated: true)
    }
}
