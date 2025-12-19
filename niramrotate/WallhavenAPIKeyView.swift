//
//  WallhavenAPIKeyView.swift
//  niramrotate
//
//  Created by aravinthan.selvaraj on 17/12/25.
//


import SwiftUI

struct WallhavenAPIKeyView: View {

    @State private var apiKey = ""
    @Environment(\.dismiss) private var dismiss
    @State private var error: String?
    @State private var isSaving = false

    var body: some View {
        Form {
            SecureField("Wallhaven API Key", text: $apiKey)

            if let error {
                Text(error)
                    .foregroundColor(.red)
            }

            Button {
                isSaving = true
                error = nil

                Task {
                    do {
                        try await WallhavenKeyManager.shared.saveKey(apiKey)
                        dismiss()
                    } catch {
                        self.error = "Failed to save key"
                        isSaving = false
                    }
                }
            } label: {
                if isSaving {
                    ProgressView()
                } else {
                    Text("Save")
                }
            }
            .disabled(apiKey.isEmpty || isSaving)
        }
        .navigationTitle("Wallhaven API Key")
    }
}
