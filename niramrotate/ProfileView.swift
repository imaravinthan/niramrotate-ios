//
//  ProfileView.swift
//  niramrotate
//
//  Created by aravinthan.selvaraj on 14/12/25.
//

import SwiftUI
import Combine

enum DangerAction {
    case clearBundles
    case resetApp
}

struct ProfileView: View {

    @State private var showClearBundlesConfirm = false
    @State private var showResetConfirm = false
    @State private var errorMessage: String?
    @StateObject private var shopPrefs = ShopPreferences.shared

    @StateObject private var keyManager = WallhavenKeyManager.shared
    @State private var showKeyEditor = false
    @State private var showReveal = false
    @State private var revealedKey: String?
    
    @State private var showDangerSheet = false
    @State private var selectedDangerAction: DangerAction?


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

                    if keyManager.hasKey {

                        HStack {
                            Text("Wallhaven API Key")
                            Spacer()
                            Text(keyManager.maskedKey ?? "")
                                .foregroundStyle(.secondary)
                        }

                        Button("View") {
                            Task {
                                do {
                                    revealedKey = try await keyManager.revealKey()
                                    showReveal = true
                                } catch {
                                    errorMessage = error.localizedDescription
                                }
                            }
                        }

                        Button("Update") {
                            showKeyEditor = true
                        }

                    } else {

                        Button("Add Wallhaven API Key") {
                            showKeyEditor = true
                        }
                    }
                }
                .sheet(isPresented: $showKeyEditor) {
                    WallhavenKeyEditorView(existingKey: revealedKey ) { newKey in
                        Task {
                            do {
                                try await keyManager.saveKey(newKey)
                            } catch {
                                errorMessage = error.localizedDescription
                            }
                        }
                    }
                }
                .sheet(isPresented: $showReveal) {
                    if let revealedKey {
                        Text(revealedKey)
                            .font(.footnote.monospaced())
                            .padding()
                    }
                }

                
                Section("Danger Zone") {

                    Button(role: .destructive) {
                        selectedDangerAction = .clearBundles
                        showDangerSheet = true
                        HapticManager.notification(.warning)
                    } label: {
                        Text("Clear All Bundles")
                    }

                    Button(role: .destructive) {
                        selectedDangerAction = .resetApp
                        showDangerSheet = true
                        HapticManager.notification(.warning)
                    } label: {
                        Text("Reset App")
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
            .overlay(alignment: .bottom) {
                if showDangerSheet, let action = selectedDangerAction {
                    DangerActionSheet(
                        action: action,
                        onConfirm: {
                            showDangerSheet = false
                            executeDangerAction(action)
                        },
                        onCancel: {
                            showDangerSheet = false
                        }
                    )
                    .transition(.move(edge: .bottom))
                }
            }
            .animation(.easeOut, value: showDangerSheet)
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
    
    private func executeDangerAction(_ action: DangerAction) {
        if AppSettings.shared.hapticsEnabled {
            HapticManager.notification(.error)
        }

        switch action {
        case .clearBundles:
            clearBundles()

        case .resetApp:
            resetApp()
        }
    }

}

