//
//  ShopFullscreenView.swift
//  niramrotate
//
//  Created by aravinthan.selvaraj on 16/12/25.
//

import SwiftUI
import UIKit

struct ShopImageFullscreenView: View {

    let imageURL: URL
    @Environment(\.dismiss) private var dismiss

    @State private var showControls = true
    @State private var downloadStatus: DownloadStatus = .idle

    @State private var tempDownloadURL: URL?
    @State private var showSavePicker = false

    var body: some View {
        ZStack {

            Color.black.ignoresSafeArea()

            ZoomableScrollView(
                imageURL: imageURL,
                onSingleTap: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        showControls.toggle()
                    }
                }
            )

            if showControls {
                topBar
                bottomBar
            }

            statusOverlay
        }
        .statusBarHidden(true)
        .sheet(isPresented: $showSavePicker) {
            if let url = tempDownloadURL {
                FileSavePicker(fileURL: url) { success in
                    downloadStatus = success ? .downloaded : .failed("Save cancelled")
                    autoDismissStatus()
                }
            }
        }
    }

    // MARK: - Top Bar
    private var topBar: some View {
        VStack {
            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(10)
                        .background(.black.opacity(0.6))
                        .clipShape(Circle())
                }
                Spacer()
            }
            .padding()
            Spacer()
        }
    }

    // MARK: - Bottom Bar
    private var bottomBar: some View {
        VStack {
            Spacer()

            HStack(spacing: 28) {

                // Save to Photos
                Button {
                    Task {
                        ImageSaveManager.save(
                            imageURL: imageURL,
                            status: { downloadStatus = $0 }
                        )
                        autoDismissStatus()
                    }
                } label: {
                    actionIcon("photo")
                }

                // Download to Files
                Button {
                    startDownload()
                } label: {
                    actionIcon("arrow.down.circle")
                }

                // Share
                Button {
                    ShareManager.share(url: imageURL)
                } label: {
                    actionIcon("square.and.arrow.up")
                }
            }
            .padding()
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .padding(.bottom, 30)
        }
    }

    // MARK: - Status Overlay
    private var statusOverlay: some View {
        VStack {
            Spacer()
            if downloadStatus != .idle {
                Text(downloadStatus.label)
                    .font(.caption)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
                    .transition(.opacity)
                    .padding(.bottom, 120)
            }
        }
    }

    // MARK: - Helpers
    private func startDownload() {
        downloadStatus = .downloading
        Task {
            do {
                tempDownloadURL = try await DownloadManager.shared.download(
                    from: imageURL
                )
                showSavePicker = true
            } catch {
                downloadStatus = .failed("Download failed")
                autoDismissStatus()
            }
        }
    }

    private func autoDismissStatus() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation {
                downloadStatus = .idle
            }
        }
    }

    private func actionIcon(_ name: String) -> some View {
        Image(systemName: name)
            .font(.title2)
            .foregroundColor(.white)
            .padding(14)
            .background(.black.opacity(0.6))
            .clipShape(Circle())
    }
}
