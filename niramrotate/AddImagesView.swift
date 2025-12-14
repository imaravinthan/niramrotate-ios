//
//  AddImagesView.swift
//  niramrotate
//
//  Created by aravinthan.selvaraj on 14/12/25.
//

import SwiftUI

struct AddImagesView: View {

    let bundle: ImageBundle
    @State private var status: String?

    var body: some View {
        VStack(spacing: 20) {
            Text("Bundle: \(bundle.name)")
                .font(.headline)

            Button("Add Test Image") {
                addTestImage()
            }

            if let status {
                Text(status)
            }

            Spacer()
        }
        .padding()
        .navigationTitle("Add Images")
    }

    private func addTestImage() {
        do {
            let dummy = Data("test-image".utf8)
            try ImageBundleStore.shared.addEncryptedImage(dummy, to: bundle)
            status = "Encrypted image added"
        } catch {
            status = "Failed to add image"
        }
    }
}
