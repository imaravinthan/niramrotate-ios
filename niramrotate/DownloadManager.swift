//
//  DownloadManager.swift
//  niramrotate
//
//  Created by aravinthan.selvaraj on 19/12/25.
//

import SwiftUI
import Foundation

@MainActor
final class DownloadManager {

    static let shared = DownloadManager()

    func download(
        from url: URL
    ) async throws -> URL {

        let (tempURL, _) = try await URLSession.shared.download(from: url)

        // ✅ Desired filename
        let filename = url.lastPathComponent

        // ✅ New temp location with correct name
        let renamedURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(filename)

        // ✅ Remove if already exists (OS will still ask user later)
        if FileManager.default.fileExists(atPath: renamedURL.path) {
            try FileManager.default.removeItem(at: renamedURL)
        }

        try FileManager.default.copyItem(
            at: tempURL,
            to: renamedURL
        )

        return renamedURL
    }
}

