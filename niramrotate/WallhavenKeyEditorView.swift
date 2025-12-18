//
//  WallhavenKeyEditorView.swift
//  niramrotate
//
//  Created by aravinthan.selvaraj on 17/12/25.
//


import SwiftUI

struct WallhavenKeyEditorView: View {

    @Environment(\.dismiss) private var dismiss
    @State private var key: String

    let onSave: (String) -> Void

    init(existingKey: String?, onSave: @escaping (String) -> Void) {
        _key = State(initialValue: existingKey ?? "")
        self.onSave = onSave
    }

    var body: some View {
        NavigationStack {
            Form {
                SecureField("API Key", text: $key)
            }
            .navigationTitle("Wallhaven API Key")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        onSave(key)
                        dismiss()
                    }
                }
            }
        }
    }
}
