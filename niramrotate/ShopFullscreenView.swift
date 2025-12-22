//
//  ShopFullscreenView.swift
//  niramrotate
//
//  Created by aravinthan.selvaraj on 16/12/25.
//

import SwiftUI

struct ShopImageFullscreenView: View {

    let imageURL: URL

    @Environment(\.dismiss) private var dismiss

    @State private var showControls = true
    @State private var downloadStatus: DownloadStatus = .idle

    @State private var tempDownloadURL: URL?
    @State private var showSavePicker = false
    @State private var reloadID = UUID()

    var body: some View {
        ZStack {

            Color.black.ignoresSafeArea()

            // 🔴 CRITICAL FIX: GeometryReader
            GeometryReader { geo in
                AsyncImage(url: imageURL) { phase in
                    switch phase {

                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(
                                width: geo.size.width,
                                height: geo.size.height
                            )
                            .contentShape(Rectangle())
                            .onTapGesture {
                                withAnimation {
                                    showControls.toggle()
                                }
                            }

                    case .failure:
                        failedView

                    default:
                        ProgressView()
                            .tint(.white)
                            .frame(
                                width: geo.size.width,
                                height: geo.size.height
                            )
                    }
                }
                .id(reloadID) // allows retry
            }

            // MARK: - Top Bar
            if showControls {
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
                .transition(.opacity)
            }

            // MARK: - Bottom Actions
            if showControls {
                VStack {
                    Spacer()

                    VStack(spacing: 12) {

                        if downloadStatus != .idle {
                            Text(downloadStatus.label)
                                .font(.caption)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(.ultraThinMaterial)
                                .clipShape(Capsule())
                        }

                        HStack(spacing: 28) {

                            Button {
                                Task {
                                    await ImageSaveManager.save(
                                        imageURL: imageURL,
                                        status: { downloadStatus = $0 }
                                    )
                                }
                            } label: {
                                actionIcon("photo")
                            }

                            Button {
                                startDownload()
                            } label: {
                                actionIcon("arrow.down.circle")
                            }

                            Button {
                                ShareManager.share(url: imageURL)
                            } label: {
                                actionIcon("square.and.arrow.up")
                            }
                        }
                        .padding()
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                    }
                    .padding(.bottom, 30)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .statusBarHidden(true)
        .sheet(isPresented: $showSavePicker) {
            if let url = tempDownloadURL {
                FileSavePicker(fileURL: url) { success in
                    downloadStatus = success ? .downloaded : .idle
                    tempDownloadURL = nil
                }
            }
        }
    }

    // MARK: - Helpers

    private var failedView: some View {
        VStack(spacing: 12) {
            Image(systemName: "wifi.exclamationmark")
                .font(.largeTitle)
                .foregroundColor(.white)

            Text("Failed to load image")
                .foregroundColor(.white.opacity(0.8))

            Button("Retry") {
                reloadID = UUID()
            }
            .foregroundColor(.blue)
        }
    }

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
