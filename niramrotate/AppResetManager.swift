//
//  AppResetManager.swift
//  niramrotate
//
//  Created by aravinthan.selvaraj on 15/12/25.
//

import Foundation

enum AppResetManager {

    static func resetApp() throws {

        // 1. Delete all bundles
        try ImageBundleStore.shared.deleteAllBundles()

        // 2. Clear UserDefaults
        let defaults = UserDefaults.standard
        if let bundleID = Bundle.main.bundleIdentifier {
            defaults.removePersistentDomain(forName: bundleID)
        }

        // 3. Sync immediately
        defaults.synchronize()
    }
}
