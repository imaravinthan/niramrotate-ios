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

    @State private var scale: CGFloat = 1
    @State private var lastScale: CGFloat = 1

    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero

    var body: some View {
        ZStack {

            Color.black.ignoresSafeArea()

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
                            .scaleEffect(scale)
                            .offset(offset)
                            .contentShape(Rectangle())

                            // 🔹 PINCH TO ZOOM
                            .gesture(
                                MagnificationGesture()
                                    .onChanged { value in
                                        let newScale = lastScale * value
                                        scale = min(max(newScale, 1), 4)
                                    }
                                    .onEnded { _ in
                                        lastScale = scale
                                        if scale == 1 {
                                            offset = .zero
                                            lastOffset = .zero
                                        }
                                    }
                            )

                            // 🔹 DOUBLE TAP TO ZOOM
                            .highPriorityGesture(
                                    TapGesture(count: 2)
                                        .onEnded {
                                            withAnimation(.spring()) {
                                                if scale > 1 {
                                                    scale = 1
                                                    lastScale = 1
                                                    offset = .zero
                                                    lastOffset = .zero
                                                } else {
                                                    scale = 2.5
                                                    lastScale = 2.5
                                                }
                                            }
                                        }
                                )
                            // 🔹 SINGLE TAP → SHOW / HIDE CONTROLS
                            .simultaneousGesture(
                                DragGesture()
                                    .onChanged { value in
                                        guard scale > 1 else { return }

                                        let newOffset = CGSize(
                                            width: lastOffset.width + value.translation.width,
                                            height: lastOffset.height + value.translation.height
                                        )

                                        offset = clampOffset(
                                            newOffset,
                                            in: geo.size,
                                            scale: scale
                                        )
                                    }
                                    .onEnded { _ in
                                        lastOffset = offset
                                    }
                                )
                        // 🔹 SINGLE TAP → SHOW / HIDE CONTROLS
                            .simultaneousGesture(
                                TapGesture(count: 1)
                                    .onEnded {
                                        withAnimation {
                                            showControls.toggle()
                                        }
                                    }
                            )

                    case .failure:
                        failedView
                            .frame(
                                width: geo.size.width,
                                height: geo.size.height
                            )

                    default:
                        ProgressView()
                            .tint(.white)
                            .frame(
                                width: geo.size.width,
                                height: geo.size.height
                            )
                    }
                }
                .id(reloadID)
            }

            // MARK: - TOP BAR
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

            // MARK: - BOTTOM CONTROLS
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
                                .transition(.opacity)
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
    
    private func clampOffset(
        _ offset: CGSize,
        in size: CGSize,
        scale: CGFloat
    ) -> CGSize {

        let maxX = (size.width * (scale - 1)) / 2
        let maxY = (size.height * (scale - 1)) / 2

        return CGSize(
            width: min(max(offset.width, -maxX), maxX),
            height: min(max(offset.height, -maxY), maxY)
        )
    }
 
}
