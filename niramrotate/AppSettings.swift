//
//  AppSettings.swift
//  niramrotate
//
//  Created by aravinthan.selvaraj on 16/12/25.
//

import Foundation

final class AppSettings {

    static let shared = AppSettings()
    private init() {}

    private let hapticsKey = "enable_haptics"

    var hapticsEnabled: Bool {
        get {
            UserDefaults.standard.bool(forKey: hapticsKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: hapticsKey)
        }
    }
}
