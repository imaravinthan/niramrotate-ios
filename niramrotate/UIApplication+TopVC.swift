//
//  UIApplication+TopVC.swift
//  niramrotate
//
//  Created by aravinthan.selvaraj on 14/12/25.
//

import UIKit

extension UIApplication {
    var topViewController: UIViewController? {
        guard let scene = connectedScenes.first as? UIWindowScene,
              let root = scene.windows.first?.rootViewController else {
            return nil
        }

        var top = root
        while let presented = top.presentedViewController {
            top = presented
        }
        return top
    }
}
