//
//  ShareManager.swift
//  niramrotate
//
//  Created by aravinthan.selvaraj on 16/12/25.
//

import UIKit

enum ShareManager {
    static func share(url: URL) {
        let vc = UIActivityViewController(
            activityItems: [url],
            applicationActivities: nil
        )

        UIApplication.shared
            .topViewController?
            .present(vc, animated: true)
    }
}
