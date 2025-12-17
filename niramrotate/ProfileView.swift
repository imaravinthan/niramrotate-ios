//
//  ProfileView.swift
//  niramrotate
//
//  Created by aravinthan.selvaraj on 14/12/25.
//

import SwiftUI
import Combine

struct ProfileView: View {

    @State private var showClearBundlesConfirm = false
    @State private var showResetConfirm = false
    @State private var errorMessage: String?
    @StateObject private var shopPrefs = ShopPreferences.shared
    @StateObject private var keyManager = WallhavenKeyManager.shared
    @State private var revealedKey: String?
    @State private var showKeyEditor = false

    var body: some View {
        NavigationStack {
            List {

                Section("Account") {
                    Text("Apple ID: Signed In")
                        .foregroundStyle(.secondary)
                }

                Section("Preferences") {
                    Toggle("Haptic Feedback", isOn: Binding(
                        get: { AppSettings.shared.hapticsEnabled },
                        set: { AppSettings.shared.hapticsEnabled = $0 }
                    ))
                    Toggle("Pin Archived", isOn: Binding(
                        get: { AppSettings.shared.pinarchiveEnabled },
                        set: { AppSettings.shared.pinarchiveEnabled = $0 }
                    ))
                     
                    Toggle("Show NFSW in Library", isOn: Binding(
                        get: { AppSettings.shared.showNSFWEnabled },
                        set: { AppSettings.shared.showNSFWEnabled = $0 }
                    ))
                    Toggle("Blur NFSW Thumbnails", isOn: Binding(
                        get: { AppSettings.shared.blurNSFWBundleEnabled },
                        set: { AppSettings.shared.blurNSFWBundleEnabled = $0 }
                    ))
                    Toggle(
                        "Show pager as dots in Bundle View",
                        isOn: Binding(
                            get: { AppSettings.shared.usePagerDots },
                            set: { AppSettings.shared.usePagerDots = $0 }
                        )
                    )
                }
                
                Section("Shop Content") {

                    Button {
                        Task {
                            revealedKey = try? await WallhavenKeyStore.loadWithBiometrics()
                            showKeyEditor = true
                        }
                    } label: {
                        HStack {
                            Text("Wallhaven API Key")
                            Spacer()
                            Text(revealedKey == nil ? "Not Set" : "••••••••")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .sheet(isPresented: $showKeyEditor) {
                    WallhavenKeyEditorView(existingKey: revealedKey) { newKey in
                        do {
                            try WallhavenKeyStore.save(newKey)
                        } catch {
                            print("❌ Failed to save API key:", error)
                        }
                    }
                }
                
                Section("Danger Zone") {

                    Button("Clear All Bundles", role: .destructive) {
                        showClearBundlesConfirm = true
                    }

                    Button("Reset App", role: .destructive) {
                        showResetConfirm = true
                    }
                }
                

                if let errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Profile")
            .confirmationDialog(
                "This will permanently delete all bundles.",
                isPresented: $showClearBundlesConfirm
            ) {
                Button("Delete All Bundles", role: .destructive) {
                    clearBundles()
                }
            }

            .confirmationDialog(
                "This will reset the entire app.",
                isPresented: $showResetConfirm
            ) {
                Button("Reset App", role: .destructive) {
                    resetApp()
                }
            }
//            .sheet(isPresented: $showKeyEditor) {
//                WallhavenKeyEditorView(existingKey: revealedKey) { newKey in
//                    Task {
//                        try? await WallhavenKeyManager.shared.save(newKey)
//                    }
//                }
//            }
        }
    }

    // MARK: - Actions

    private func clearBundles() {
        do {
            try ImageBundleStore.shared.clearAllBundles()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func resetApp() {
        do {
            try AppResetManager.resetApp()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

