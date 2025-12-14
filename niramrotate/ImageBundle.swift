//
//  ImageBundle.swift
//  niramrotate
//
//  Created by aravinthan.selvaraj on 14/12/25.
//

import Foundation

struct ImageBundle: Identifiable, Codable {
    let id: UUID
    var name: String
    var imageCount: Int
    var createdAt: Date
    var thumbnailFilename: String?
}
