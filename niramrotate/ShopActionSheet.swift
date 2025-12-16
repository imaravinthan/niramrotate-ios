//
//  ShopActionSheet.swift
//  niramrotate
//
//  Created by aravinthan.selvaraj on 16/12/25.
//

import SwiftUI

struct ShopActionSheet: View {

    let wallpaper: ShopWallpaper
    let onSelect: (ShopPostAction) -> Void
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 12) {

            Capsule()
                .fill(Color.secondary.opacity(0.5))
                .frame(width: 40, height: 5)
                .padding(.top, 8)

            actionButton("Download", systemImage: "arrow.down.to.line") {
                onSelect(.download)
            }

            actionButton("Share", systemImage: "square.and.arrow.up") {
                onSelect(.share)
            }

            actionButton("View Fullscreen", systemImage: "arrow.up.left.and.arrow.down.right") {
                onSelect(.fullscreen)
            }

            actionButton("Details", systemImage: "info.circle") {
                onSelect(.details)
            }

            Button("Cancel", role: .cancel) {
                onDismiss()
            }
            .padding(.top, 8)

        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(16)
        .padding()
    }

    private func actionButton(
        _ title: String,
        systemImage: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack {
                Image(systemName: systemImage)
                Text(title)
                Spacer()
            }
            .padding()
        }
    }
}
