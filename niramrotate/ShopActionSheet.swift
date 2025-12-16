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

            actionButton(
                "Download",
                systemImage: "arrow.down.to.line",
                foreground: .blue
            ) {
                onSelect(.download)
            }

            actionButton(
                "Share",
                systemImage: "square.and.arrow.up",
                foreground: .blue
            ) {
                onSelect(.share)
            }

            actionButton(
                "View Fullscreen",
                systemImage: "arrow.up.left.and.arrow.down.right",
                foreground: .blue
            ) {
                onSelect(.fullscreen)
            }

            actionButton(
                "Details",
                systemImage: "info.circle",
                foreground: .blue
            ) {
                onSelect(.details)
            }

            // 🔴 Cancel — red text, no capsule
            Button("Cancel", role: .cancel) {
                onDismiss()
            }
            .font(.headline.bold())
            .foregroundColor(.red)
            .padding(.top, 8)

        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(16)
        .padding()
    }

    @ViewBuilder
    private func actionButton(
        _ title: String,
        systemImage: String,
        role: ButtonRole? = nil,
        foreground: Color = .blue,
        font: Font = .headline,
        background: Color = .white.opacity(0.2),
        action: @escaping () -> Void
    ) -> some View {
        Button(role: role, action: action) {
            Label(title, systemImage: systemImage)
                .font(font)
                .fontWeight(.bold)
                .foregroundColor(foreground)
                .frame(maxWidth: .infinity)
                .padding()
                .background(background)
                .clipShape(Capsule())
        }
    }

}
