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

    var body: some View {
        Form {
            SecureField("Wallhaven API Key", text: $apiKey)

            if let error {
                Text(error).foregroundColor(.red)
            }

            Button("Save") {
                do {
                    try WallhavenKeyStore.save(apiKey)
                    dismiss()
                } catch {
                    self.error = "Failed to save key"
                }
            }
            .disabled(apiKey.isEmpty)
        }
        .navigationTitle("Wallhaven API Key")
    }
}
