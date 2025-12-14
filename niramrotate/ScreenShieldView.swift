//
//  ScreenShieldView.swift
//  niramrotate
//
//  Created by aravinthan.selvaraj on 14/12/25.
//

import SwiftUI

struct ScreenShieldView: View {
    @Environment(\.scenePhase) private var scenePhase
    @State private var isCaptured = false

    var body: some View {
        Group {
            if isCaptured {
                Color.black
                    .overlay(
                        Text("Content Hidden")
                            .foregroundColor(.white)
                            .font(.headline)
                    )
            } else {
                Color.clear
            }
        }
        .ignoresSafeArea()
        .onAppear {
            updateCaptureState()
        }
        .onReceive(
            NotificationCenter.default.publisher(
                for: UIScreen.capturedDidChangeNotification
            )
        ) { _ in
            updateCaptureState()
        }
    }

    private func updateCaptureState() {
        guard
            let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
            let window = scene.windows.first
        else {
            return
        }

        isCaptured = window.screen.isCaptured
    }
}
