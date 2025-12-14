//
//  ImageBundleStore.swift
//  niramrotate
//
//  Created by aravinthan.selvaraj on 14/12/25.
//

import Foundation
import UIKit

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
    
    func listEncryptedImages(for bundle: ImageBundle) -> [URL] {
        let imagesURL = baseURL
            .appendingPathComponent(bundle.id.uuidString)
            .appendingPathComponent("images")

        let files = (try? FileManager.default.contentsOfDirectory(
            at: imagesURL,
            includingPropertiesForKeys: nil
        )) ?? []

        return files.filter { $0.pathExtension == "enc" }
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

        let filename = UUID().uuidString + ".enc"
        let fileURL = imagesURL.appendingPathComponent(filename)

        // 1. Save encrypted image
        try SecureFileStore.shared.saveEncrypted(data, to: fileURL)

        // 2. Update manifest ONCE
        let manifestURL = bundleURL.appendingPathComponent("manifest.json")
        let manifestData = try Data(contentsOf: manifestURL)
        var updatedBundle = try JSONDecoder().decode(ImageBundle.self, from: manifestData)

        updatedBundle.imageCount += 1

        let updatedData = try JSONEncoder().encode(updatedBundle)
        try updatedData.write(to: manifestURL, options: .atomic)
    }
    
    func loadRandomThumbnail(for bundle: ImageBundle) -> UIImage? {
        let imagesURL = baseURL
            .appendingPathComponent(bundle.id.uuidString)
            .appendingPathComponent("images")

        guard
            let files = try? FileManager.default.contentsOfDirectory(
                at: imagesURL,
                includingPropertiesForKeys: nil
            ),
            let random = files.filter({ $0.pathExtension == "enc" }).randomElement(),
            let decrypted = try? SecureFileStore.shared.loadDecrypted(from: random),
            let image = UIImage(data: decrypted)
        else {
            return nil
        }

        return image
    }

}


