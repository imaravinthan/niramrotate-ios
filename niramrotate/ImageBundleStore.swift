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

    // MARK: - Bundle CRUD

    func createBundle(name: String) throws -> ImageBundle {
        let bundle = ImageBundle(
            id: UUID(),
            name: name,
            imageCount: 0,
            createdAt: Date()
        )

        let bundleURL = baseURL.appendingPathComponent(bundle.id.uuidString)
        let imagesURL = bundleURL.appendingPathComponent("images")

        try FileManager.default.createDirectory(at: imagesURL, withIntermediateDirectories: true)

        let manifestURL = bundleURL.appendingPathComponent("manifest.json")
        let data = try JSONEncoder().encode(bundle)
        try data.write(to: manifestURL)

        return bundle
    }

    func loadAllBundles() -> [ImageBundle] {
        guard let folders = try? FileManager.default.contentsOfDirectory(
            at: baseURL,
            includingPropertiesForKeys: nil
        ) else { return [] }

        return folders.compactMap { folder in
            let manifest = folder.appendingPathComponent("manifest.json")
            guard
                let data = try? Data(contentsOf: manifest),
                let bundle = try? JSONDecoder().decode(ImageBundle.self, from: data)
            else { return nil }
            return bundle
        }
        .sorted { $0.createdAt > $1.createdAt }
    }

    // MARK: - Images

    func addEncryptedImage(_ data: Data, to bundle: ImageBundle) throws {
        let bundleURL = baseURL.appendingPathComponent(bundle.id.uuidString)
        let imagesURL = bundleURL.appendingPathComponent("images")

        let fileURL = imagesURL.appendingPathComponent(UUID().uuidString + ".enc")
        try SecureFileStore.shared.saveEncrypted(data, to: fileURL)

        // update manifest
        let manifestURL = bundleURL.appendingPathComponent("manifest.json")
        let manifestData = try Data(contentsOf: manifestURL)
        var updated = try JSONDecoder().decode(ImageBundle.self, from: manifestData)
        updated.imageCount += 1
        let newData = try JSONEncoder().encode(updated)
        try newData.write(to: manifestURL, options: .atomic)
    }

    func randomImage(for bundle: ImageBundle) -> UIImage? {
        let imagesURL = baseURL
            .appendingPathComponent(bundle.id.uuidString)
            .appendingPathComponent("images")

        guard
            let files = try? FileManager.default.contentsOfDirectory(at: imagesURL, includingPropertiesForKeys: nil),
            let random = files.randomElement(),
            let data = try? SecureFileStore.shared.loadDecrypted(from: random),
            let image = UIImage(data: data)
        else {
            return nil
        }

        return image
    }

    func allImages(for bundle: ImageBundle) -> [UIImage] {
        let imagesURL = baseURL
            .appendingPathComponent(bundle.id.uuidString)
            .appendingPathComponent("images")

        guard let files = try? FileManager.default.contentsOfDirectory(at: imagesURL, includingPropertiesForKeys: nil)
        else { return [] }

        return files.compactMap {
            guard let data = try? SecureFileStore.shared.loadDecrypted(from: $0)
            else { return nil }
            return UIImage(data: data)
        }
    }
    
    func listEncryptedImages(forID bundleID: UUID) -> [URL] {
        let imagesURL = baseURL
            .appendingPathComponent(bundleID.uuidString)
            .appendingPathComponent("images")

        let files = (try? FileManager.default.contentsOfDirectory(
            at: imagesURL,
            includingPropertiesForKeys: nil
        )) ?? []

        return files.filter { $0.pathExtension == "enc" }
    }


    func loadRandomDecryptedImage(forID bundleID: UUID) -> UIImage? {
        let images = listEncryptedImages(forID: bundleID)
        guard let file = images.randomElement(),
              let data = try? SecureFileStore.shared.loadDecrypted(from: file),
              let image = UIImage(data: data)
        else { return nil }

        return image
    }

    
    func loadRandomDecryptedImageFromAnyBundle() -> UIImage? {
        let bundles = loadAllBundles()
        guard let bundle = bundles.randomElement() else { return nil }

        let images = listEncryptedImages(forID: bundle.id)
        guard let file = images.randomElement() else { return nil }

        guard
            let data = try? SecureFileStore.shared.loadDecrypted(from: file),
            let image = UIImage(data: data)
        else {
            return nil
        }

        return image
    }
    
    private func updateLastIndex(bundleID: UUID, index: Int) {
        let manifestURL = baseURL
            .appendingPathComponent(bundleID.uuidString)
            .appendingPathComponent("manifest.json")

        guard
            let data = try? Data(contentsOf: manifestURL),
            var bundle = try? JSONDecoder().decode(ImageBundle.self, from: data)
        else { return }

        bundle.lastIndex = index

        if let newData = try? JSONEncoder().encode(bundle) {
            try? newData.write(to: manifestURL, options: .atomic)
        }
    }

    
    func nextWallpaper(for bundleID: UUID) throws -> Data {
        let images = listEncryptedImages(forID: bundleID)
        guard !images.isEmpty else {
            throw NSError(domain: "NoImages", code: 0)
        }

        let historyKey = "history-\(bundleID.uuidString)"
        var used = Set(UserDefaults.standard.stringArray(forKey: historyKey) ?? [])

        let available = images.filter { !used.contains($0.lastPathComponent) }
        let chosen = available.randomElement() ?? images.randomElement()!

        used.insert(chosen.lastPathComponent)
        if used.count > images.count / 2 {
            used.removeAll()
        }

        UserDefaults.standard.set(Array(used), forKey: historyKey)

        return try SecureFileStore.shared.loadDecrypted(from: chosen)
    }



    func nextWallpaperData() throws -> Data? {
        let bundles = loadAllBundles()
        guard let bundle = bundles.randomElement() else { return nil }

        let images = listEncryptedImages(forID: bundle.id)
        guard let file = images.randomElement() else { return nil }

        return try SecureFileStore.shared.loadDecrypted(from: file)
    }

    func bundle(named name: String) -> ImageBundle? {
        loadAllBundles().first {
            $0.name.lowercased() == name.lowercased()
        }
    }
}
