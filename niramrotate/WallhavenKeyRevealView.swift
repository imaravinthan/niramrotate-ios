//
//  WallhavenKeyRevealView.swift
//  niramrotate
//
//  Created by aravinthan.selvaraj on 18/12/25.
//

import SwiftUI


struct WallhavenKeyRevealView: View {

    let keyManager: WallhavenKeyManager
    @State private var key: String?
    @State private var error: String?

    var body: some View {
        VStack {
            if let key {
                Text(key)
                    .font(.footnote.monospaced())
                    .padding()
            } else if let error {
                Text(error).foregroundColor(.red)
            } else {
                ProgressView("Authenticating…")
            }
        }
        .task {
            do {
                key = try await keyManager.revealKey()
                HapticManager.notification(.success)
            } catch {
                self.error = error.localizedDescription
                HapticManager.notification(.error)
            }
        }
        .presentationDetents([.medium])
    }
}
