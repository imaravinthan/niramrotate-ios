//
//  DownloadStatus.swift
//  niramrotate
//
//  Created by aravinthan.selvaraj on 19/12/25.
//

import Foundation

enum DownloadStatus: Equatable {

    case idle
    case downloading
    case downloaded
    case saving
    case saved
    case failed(String)

    var label: String {
        switch self {
        case .idle:
            return ""
        case .downloading:
            return "Downloading…"
        case .downloaded:
            return "Downloaded"
        case .saving:
            return "Saving…"
        case .saved:
            return "Saved"
        case .failed(let message):
            return message
        }
    }
    
    var shouldAutoDismiss: Bool {
        switch self {
        case .downloaded, .saved, .failed:
            return true
        default:
            return false
        }
    }    
}

