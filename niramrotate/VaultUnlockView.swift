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
                    BundleListView()
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

        guard context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) else {
            errorMessage = "Authentication not available"
            return
        }

        context.evaluatePolicy(
            .deviceOwnerAuthentication,
            localizedReason: "Unlock encrypted wallpaper vault"
        ) { success, _ in
            DispatchQueue.main.async {
                if success {
                    self.isUnlocked = true
                    self.errorMessage = nil

                    DispatchQueue.global(qos: .utility).async {
                        _ = try? KeyStore.getOrCreateKey()
                    }

                } else {
                    self.errorMessage = "Authentication failed"
                }
            }
        }
    }

    
//    private func testBundleCreation() {
//        DispatchQueue.global(qos: .userInitiated).async {
//            do {
//                let bundle = try ImageBundleStore.shared.createBundle(name: "Test Bundle")
//
//                let sampleData = Data("hello-image".utf8)
//
//                try ImageBundleStore.shared.addEncryptedImage(
//                    sampleData,
//                    to: bundle
//                )
//
//                print("✅ Test bundle created:", bundle.id)
//
//            } catch {
//                print("❌ Bundle test failed:", error)
//            }
//        }
//    }


}
