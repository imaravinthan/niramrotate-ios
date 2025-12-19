//
//  AppResetManager.swift
//  niramrotate
//
//  Created by aravinthan.selvaraj on 15/12/25.
//

import Foundation

enum AppResetManager {

    static func resetApp() throws {

//        // 1. Delete all bundles
//        try ImageBundleStore.shared.deleteAllBundles()
//
//        // 2. Clear UserDefaults
//        let defaults = UserDefaults.standard
//        if let bundleID = Bundle.main.bundleIdentifier {
//            defaults.removePersistentDomain(forName: bundleID)
//        }
//        
//        // 3. Clear API keys
//        try?WallhavenKeyStore.deleteKey()
//        
////         4. Sync immediately
////        defaults.synchronize()
//        // 4. Kill the App
//        exit(0)
            // Clear bundles

            // Clear bundles
            try ImageBundleStore.shared.clearAllBundles()

            // Clear UserDefaults
            if let domain = Bundle.main.bundleIdentifier {
                UserDefaults.standard.removePersistentDomain(forName: domain)
            }

            // Clear API Key
//            try? WallhavenKeyManager.shared.deleteKey()
            try WallhavenKeyManager.shared.clear()
                UserDefaults.standard.removePersistentDomain(
                    forName: Bundle.main.bundleIdentifier!
                )
//            try WallhavenKeyStore.delete()
            // Kill app state
            exit(0)
    }
}
