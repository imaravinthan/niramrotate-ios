//
//  HapticManager.swift
//  niramrotate
//
//  Created by aravinthan.selvaraj on 16/12/25.
//

import UIKit

enum HapticManager {

    static func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        guard AppSettings.shared.hapticsEnabled else { return }
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }

    static func notification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        guard AppSettings.shared.hapticsEnabled else { return }
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(type)
    }
}
