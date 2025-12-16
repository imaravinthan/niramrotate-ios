//
//  ImageDownloader.swift
//  niramrotate
//
//  Created by aravinthan.selvaraj on 16/12/25.
//

import UIKit
import Photos

import UIKit

enum ImageDownloader {
    static func saveToPhotos(url: URL) {
        Task {
            guard
                let data = try? Data(contentsOf: url),
                let image = UIImage(data: data)
            else { return }

            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        }
    }
}
