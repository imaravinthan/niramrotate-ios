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

        return root.topMost
    }
}
private extension UIViewController {

    var topMost: UIViewController {
        if let presented = presentedViewController {
            return presented.topMost
        }
        if let nav = self as? UINavigationController {
            return nav.visibleViewController?.topMost ?? nav
        }
        if let tab = self as? UITabBarController {
            return tab.selectedViewController?.topMost ?? tab
        }
        return self
    }
}
