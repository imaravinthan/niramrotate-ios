//
//  VaultUnlockView.swift
//  niramrotate
//
//  Created by aravinthan.selvaraj on 14/12/25.
//

import SwiftUI
import LocalAuthentication

struct VaultUnlockView: View {
    @Environment(\.scenePhase) private var scenePhase
    @State private var isUnlocked = false
    @State private var errorMessage: String?

    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                if isUnlocked {
                    Text("Vault Unlocked")
                        .font(.title)
                } else {
                    Button("Unlock Vault") {
                        authenticate()
                    }

                    if let errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
            }

            ScreenShieldView()
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase != .active {
                isUnlocked = false
            }
        }
    }

    private func authenticate() {
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            context.evaluatePolicy(
                .deviceOwnerAuthentication,
                localizedReason: "Unlock encrypted wallpaper vault"
            ) { success, _ in
                DispatchQueue.main.async {
                    self.isUnlocked = success
                    if !success {
                        self.errorMessage = "Authentication failed"
                    }
                }
                if success {
                    DispatchQueue.global(qos: .userInitiated).async {
                        _ = try? KeyStore.getOrCreateKey()
//                        try? SecureFileStore.shared.saveEncrypted(
//                            Data("test".utf8),
//                            filename: "test.enc"
//                        )
                    }
                }
            }
        } else {
            errorMessage = "Authentication not available"
        }
    }
}
