//
//  DangerActionSheet.swift
//  niramrotate
//
//  Created by aravinthan.selvaraj on 18/12/25.
//


import SwiftUI

struct DangerActionSheet: View {

    let action: DangerAction
    let onConfirm: () -> Void
    let onCancel: () -> Void

    var body: some View {
        VStack(spacing: 16) {

            Capsule()
                .fill(Color.secondary.opacity(0.5))
                .frame(width: 40, height: 5)
                .padding(.top, 8)

            Text(title)
                .font(.title3.bold())
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)

            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Button {
                if AppSettings.shared.hapticsEnabled {
                    HapticManager.notification(.error)
                }
                onConfirm()
            } label: {
                Text(confirmText)
                    .font(.headline.bold())
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red.opacity(0.9))
                    .foregroundColor(.white)
                    .clipShape(Capsule())
            }

            Button {
                onCancel()
            } label: {
                Text("Cancel")
                    .font(.headline.bold())
                    .foregroundColor(.blue)
            }
            .padding(.top, 4)
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(18)
        .padding()
    }

    private var title: String {
        switch action {
        case .clearBundles:
            return "Clear all bundles?"
        case .resetApp:
            return "Reset entire app?"
        }
    }

    private var message: String {
        switch action {
        case .clearBundles:
            return "All bundles and images will be permanently deleted."
        case .resetApp:
            return "This will remove all data, settings, and API keys."
        }
    }

    private var confirmText: String {
        switch action {
        case .clearBundles:
            return "Delete All Bundles"
        case .resetApp:
            return "Reset App"
        }
    }
}
