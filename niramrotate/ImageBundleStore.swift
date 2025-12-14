//
//  ImageBundleStore.swift
//  niramrotate
//
//  Created by aravinthan.selvaraj on 14/12/25.
//

import Foundation

final class ImageBundleStore {

    static let shared = ImageBundleStore()
    private init() {}

    private let baseURL: URL = {
        let url = FileManager.default.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        )[0]
        let bundles = url.appendingPathComponent("Bundles", isDirectory: true)
        try? FileManager.default.createDirectory(
            at: bundles,
            withIntermediateDirectories: true
        )
        return bundles
    }()

    func createBundle(name: String) throws -> ImageBundle {
        let bundle = ImageBundle(
            id: UUID(),
            name: name,
            imageCount: 0,
            createdAt: Date()
        )

        let bundleURL = baseURL.appendingPathComponent(bundle.id.uuidString)
        let imagesURL = bundleURL.appendingPathComponent("images")

        try FileManager.default.createDirectory(
            at: imagesURL,
            withIntermediateDirectories: true
        )

        let manifestURL = bundleURL.appendingPathComponent("manifest.json")
        let data = try JSONEncoder().encode(bundle)
        try data.write(to: manifestURL)

        return bundle
    }
    
    func loadAllBundles() -> [ImageBundle] {
        let fm = FileManager.default

        guard let bundleFolders = try? fm.contentsOfDirectory(
            at: baseURL,
            includingPropertiesForKeys: nil
        ) else {
            return []
        }

        var bundles: [ImageBundle] = []

        for folder in bundleFolders {
            let manifestURL = folder.appendingPathComponent("manifest.json")

            if let data = try? Data(contentsOf: manifestURL),
               let bundle = try? JSONDecoder().decode(ImageBundle.self, from: data) {
                bundles.append(bundle)
            }
        }

        return bundles.sorted { $0.createdAt > $1.createdAt }
    }

}

extension ImageBundleStore {

    func addEncryptedImage(
        _ data: Data,
        to bundle: ImageBundle
    ) throws {

        let bundleURL = baseURL.appendingPathComponent(bundle.id.uuidString)
        let imagesURL = bundleURL.appendingPathComponent("images")

        try FileManager.default.createDirectory(
            at: imagesURL,
            withIntermediateDirectories: true
        )

        let fileURL = imagesURL.appendingPathComponent(
            UUID().uuidString + ".enc"
        )

        try SecureFileStore.shared.saveEncrypted(
            data,
            to: fileURL
        )

        updateManifest(bundle, increment: 1)
    }



    private func updateManifest(
        _ bundle: ImageBundle,
        increment: Int
    ) {
        let manifestURL = baseURL
            .appendingPathComponent(bundle.id.uuidString)
            .appendingPathComponent("manifest.json")

        var updated = bundle
        updated.imageCount += increment

        if let data = try? JSONEncoder().encode(updated) {
            try? data.write(to: manifestURL)
        }
    }
}
