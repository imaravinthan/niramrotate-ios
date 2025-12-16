//
//  BundleExporter.swift
//  niramrotate
//
//  Created by aravinthan.selvaraj on 16/12/25.
//

import UIKit

enum BundleExporter {
    
    static func export(_ bundle: ImageBundle) {
        do {
            let zipURL = try exportAsZip([bundle])
            presentShareSheet(for: zipURL)
        } catch {
            print("Single export failed:", error)
        }
    }

    static func exportAsZip(_ bundles: [ImageBundle]) throws -> URL {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("BundlesExport", isDirectory: true)

        try? FileManager.default.removeItem(at: tempDir)
        try FileManager.default.createDirectory(
            at: tempDir,
            withIntermediateDirectories: true
        )

        for bundle in bundles {
            let bundleDir = tempDir.appendingPathComponent(bundle.name)
            try FileManager.default.createDirectory(
                at: bundleDir,
                withIntermediateDirectories: true
            )

            let images = ImageBundleStore.shared.listEncryptedImages(forID: bundle.id)
            for (index, file) in images.enumerated() {
                let data = try SecureFileStore.shared.loadDecrypted(from: file)
                let imageURL = bundleDir.appendingPathComponent("\(index).jpg")
                try data.write(to: imageURL)
            }
        }

        // NOTE: zipping requires a ZIP implementation (e.g., ZIPFoundation or similar).
        // The previous call `FileManager.default.zipItem` is not part of Foundation.
        // For now, return the prepared export directory so callers can share/export the folder directly.
        // TODO: Integrate a ZIP library and replace this with real zipping.
        return tempDir
    }

    static func presentShareSheet(for url: URL) {
        let vc = UIActivityViewController(
            activityItems: [url],
            applicationActivities: nil
        )

        UIApplication.shared
            .connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.keyWindow }
            .first?
            .rootViewController?
            .present(vc, animated: true)
    }
}

