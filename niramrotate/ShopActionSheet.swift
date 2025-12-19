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
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(spacing: 12) {

            // Drag indicator
            Capsule()
                .fill(Color.secondary.opacity(0.4))
                .frame(width: 40, height: 5)
                .padding(.top, 8)

            // MARK: - Main actions
            VStack(spacing: 0) {
//                sheetButton("Download") {
//                    onSelect(.download)
//                }
//                divider
//                sheetButton("Share") {
//                    onSelect(.share)
//                }
//                divider
//                sheetButton("View Fullscreen") {
//                    onSelect(.fullscreen)
//                }
//                divider
//                sheetButton("Details") {
//                    onSelect(.details)
//                }
                sheetButton("Download") {
                    HapticManager.impact(.medium)
                    onSelect(.download)
                }
                divider
                sheetButton("Share") {
                    HapticManager.impact(.medium)
                    onSelect(.share)
                }
                divider
                sheetButton("Show Original Size") {
                    HapticManager.impact(.medium)
                    onSelect(.fullscreen)
                }
                divider
                sheetButton("Details") {
                    HapticManager.impact(.medium)
                    onSelect(.details)
                }
            }
            .background(
                backgroundColor
                    .background(.ultraThinMaterial)
            )
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .shadow(color: .black.opacity(0.15), radius: 10)
            .animation(.easeInOut(duration: 0.2), value: colorScheme)
            // MARK: - Cancel (separate block)
            Button {
                onDismiss()
                HapticManager.impact(.medium)
            } label: {
                Text("Cancel")
                    .font(.headline.bold())
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        backgroundColor
                            .background(.ultraThinMaterial)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .shadow(color: .black.opacity(0.15), radius: 10)
                    .animation(.easeInOut(duration: 0.2), value: colorScheme)
            }

        }
        .padding()
        .background(Color.black.opacity(0.15)) // dim behind
        .ignoresSafeArea()
    }

    // MARK: - Helpers

    private var divider: some View {
        Divider().opacity(0.5)
    }
    
    private var backgroundColor: Color {
        if colorScheme == .dark {
            Color.black.opacity(0.85)
        } else {
            Color.white.opacity(0.92)
        }
    }


    private func sheetButton(
        _ title: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .foregroundColor(.blue)
                .frame(maxWidth: .infinity)
                .padding()
        }
    }
}
