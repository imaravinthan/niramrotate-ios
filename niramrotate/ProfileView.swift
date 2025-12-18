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

enum ActiveKeySheet: Identifiable {
    case add
    case update
    case reveal

    var id: String {
        switch self {
        case .add: return "add"
        case .update: return "update"
        case .reveal: return "reveal"
        }
    }
}


struct ProfileView: View {

    @State private var showClearBundlesConfirm = false
    @State private var showResetConfirm = false
    @State private var errorMessage: String?
    
    @State private var showDangerSheet = false
    @State private var selectedDangerAction: DangerAction?
    
    @State private var activeKeySheet: ActiveKeySheet?
    @State private var revealedKey: String?
    
    @StateObject private var shopPrefs = ShopPreferences.shared
    @StateObject private var keyManager = WallhavenKeyManager.shared

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
                            HapticManager.notification(.success)
                            activeKeySheet = .reveal
                        }

                        Button("Update") {
                            HapticManager.impact(.medium)
                            activeKeySheet = .update
                        }

                    } else {

                        Button("Add Wallhaven API Key") {
                            HapticManager.impact(.medium)
                            activeKeySheet = .add
                        }
                    }
                }
                .sheet(item: $activeKeySheet) { sheet in
                    switch sheet {

                    case .add, .update:
                        WallhavenKeyEditorView(existingKey: revealedKey) { newKey in
                            Task {
                                do {
                                    try await keyManager.saveKey(newKey)
                                    HapticManager.notification(.success)
                                } catch {
                                    errorMessage = error.localizedDescription
                                    HapticManager.notification(.error)
                                }
                            }
                        }

                    case .reveal:
                        WallhavenKeyRevealView(
                            keyManager: keyManager
                        )
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

