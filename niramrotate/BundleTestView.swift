//
//  BundleTestView.swift
//  niramrotate
//
//  Created by aravinthan.selvaraj on 14/12/25.
//

import SwiftUI

struct BundleTestView: View {

    @State private var log: String = "Ready"

    var body: some View {
        VStack(spacing: 20) {

            Button("Create Bundle") {
                createBundle()
            }

            Button("Add Test Image") {
                addImage()
            }

            Text(log)
                .font(.footnote)
                .foregroundColor(.gray)
                .padding()
        }
        .padding()
    }

    private func createBundle() {
        do {
            let bundle = try ImageBundleStore.shared.createBundle(name: "Test Bundle")
            log = "✅ Bundle created: \(bundle.id.uuidString)"
            UserDefaults.standard.set(bundle.id.uuidString, forKey: "testBundleID")
        } catch {
            log = "❌ Bundle failed"
        }
    }

    private func addImage() {
        guard
            let id = UserDefaults.standard.string(forKey: "testBundleID"),
            let uuid = UUID(uuidString: id)
        else {
            log = "❌ Create bundle first"
            return
        }

        let bundle = ImageBundle(
            id: uuid,
            name: "Test Bundle",
            imageCount: 0,
            createdAt: Date()
        )

        do {
            let data = Data("fake image data".utf8)
            try ImageBundleStore.shared.addEncryptedImage(data, to: bundle)
            log = "✅ Encrypted image added"
        } catch {
            log = "❌ Add image failed"
        }
    }
}
