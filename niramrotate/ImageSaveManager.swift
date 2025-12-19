//
//  ImageSaveManager.swift
//  niramrotate
//
//  Created by aravinthan.selvaraj on 19/12/25.
//


import Photos
import UIKit

import Photos
import UIKit

@MainActor
final class ImageSaveManager {

    static func save(
        imageURL: URL,
        status: @escaping (DownloadStatus) -> Void
    ) {

        status(.saving)

        Task {
            do {
                // Step 1: Download image
                let (data, _) = try await URLSession.shared.data(from: imageURL)

                guard let image = UIImage(data: data) else {
                    status(.failed("Invalid image"))
                    return
                }

                // Step 2: Save to Photos
                PHPhotoLibrary.requestAuthorization { auth in
                    guard auth == .authorized || auth == .limited else {
                        status(.failed("Photos permission denied"))
                        return
                    }

                    PHPhotoLibrary.shared().performChanges({
                        PHAssetChangeRequest.creationRequestForAsset(
                            from: image
                        )
                    }) { success, _ in
                        DispatchQueue.main.async {
                            success
                                ? status(.saved)
                                : status(.failed("Save failed"))
                        }
                    }
                }

            } catch {
                status(.failed("Download failed"))
            }
        }
    }
}

