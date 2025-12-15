//
//  ProfileView.swift
//  niramrotate
//
//  Created by aravinthan.selvaraj on 14/12/25.
//

import SwiftUI

struct ProfileView: View {

    @State private var showClearBundlesConfirm = false
    @State private var showResetConfirm = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            List {

                Section("Account") {
                    Text("Apple ID: Signed In")
                        .foregroundStyle(.secondary)
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
