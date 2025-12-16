//
//  AppSettings.swift
//  niramrotate
//
//  Created by aravinthan.selvaraj on 16/12/25.
//
import Foundation
import Combine

@MainActor
final class AppSettings: ObservableObject {

    static let shared = AppSettings()

    private let hapticsKey = "enable_haptics"
    private let pinarchiveKey = "enable_pinarchive"
    private let shownsfwKey = "enable_shownsfw"
    private let blurnsfwbundleKey = "enable_blurnsfwbundle"

    @Published var hapticsEnabled: Bool {
        didSet { UserDefaults.standard.set(hapticsEnabled, forKey: hapticsKey) }
    }

    @Published var pinarchiveEnabled: Bool {
        didSet { UserDefaults.standard.set(pinarchiveEnabled, forKey: pinarchiveKey) }
    }

    @Published var showNSFWEnabled: Bool {
        didSet { UserDefaults.standard.set(showNSFWEnabled, forKey: shownsfwKey) }
    }

    @Published var blurNSFWBundleEnabled: Bool {
        didSet { UserDefaults.standard.set(blurNSFWBundleEnabled, forKey: blurnsfwbundleKey) }
    }

    private init() {
        self.hapticsEnabled =
            UserDefaults.standard.bool(forKey: hapticsKey)

        self.pinarchiveEnabled =
            UserDefaults.standard.bool(forKey: pinarchiveKey)

        self.showNSFWEnabled =
            UserDefaults.standard.bool(forKey: shownsfwKey)

        self.blurNSFWBundleEnabled =
            UserDefaults.standard.bool(forKey: blurnsfwbundleKey)
    }
}
