//
//  ShopFullDetailsView.swift
//  niramrotate
//
//  Created by aravinthan.selvaraj on 19/12/25.
//

//
//#Preview("Shop Feed – Static") {
//        let prefs = ShopPreferences.shared
//        prefs._setHasWallhavenKeyForPreview(true)
//    
//        return ShopFullDetailsView(
//        wallpaper: .previewAPIKEY
//        )
////            .previewLandscape,
////            .previewNSFW
//}

import SwiftUI

struct ShopFullDetailsView: View {

    let wallpaper: ShopWallpaper
    let onTagSelected: (String) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var details: ShopWallpaperDetails?
    @State private var isLoading = true
    @State private var downloadStatus: DownloadStatus = .idle
    @State private var pendingDownload = false
    
    @State private var tempDownloadURL: URL?
    @State private var showSavePicker = false
    @State private var showFullscreenImage = false
    
    @State private var reloadToken = UUID()


    var body: some View {
        VStack(spacing: 0) {

            headerBar

            ScrollView {
                VStack(spacing: 16) {

                    fullImage

                    statusView

                    metaSection

                    if isLoading {
                        ProgressView("Loading details…")
                    }

                    if let details {
                        uploaderSection(details)
                        tagsSection(details)
                    }
                }
                .padding()
            }
        }
        .onAppear {
            loadDetailsIfNeeded()
        }
        .sheet(isPresented: $showSavePicker) {
            if let tempDownloadURL {
                FileSavePicker(fileURL: tempDownloadURL) { success in
                    downloadStatus = success ? .downloaded : .idle
                    self.tempDownloadURL = nil
                }
            }
        }
    }


    private func loadDetails() {
        Task {
            do {
//                let key = try await WallhavenKeyStore.loadSilently()
                guard let key = WallhavenKeyManager.shared.getKeySilently() else {
                    throw NSError(domain: "No API key", code: 401)
                }

                details = try await WallhavenAPI.fetchDetails(
                    id: wallpaper.id,
                    apiKey: key
                )
            } catch {
                print("❌ Details error:", error)
            }
            isLoading = false
        }
    }
    
    private func loadDetailsIfNeeded() {
        Task {
            do {
//                let key = try await WallhavenKeyStore.loadSilently()
                guard let key = WallhavenKeyManager.shared.getKeySilently() else {
                    throw NSError(domain: "No API key", code: 401)
                }

                details = try await WallhavenAPI.fetchDetails(
                    id: wallpaper.id,
                    apiKey: key
                )
            } catch {
                print("❌ Details error:", error)
            }
            isLoading = false
        }
    }
    
    private func handleTagTap(_ tag: ShopTag) {
        dismiss()                    // close details
        onTagSelected(tag.name)      // trigger search
    }

    private var statusView: some View {
        Group {
            switch downloadStatus {
            case .idle:
                EmptyView()
            default:
                Text(downloadStatus.label)
                    .font(.caption)
                    .padding(8)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
                    .transition(.opacity)
            }
        }
    }

    private func detailsSection(_ details: ShopWallpaperDetails) -> some View {
        VStack(alignment: .leading, spacing: 12) {

//            Text("Uploaded by \(details.uploaderName)")
//                .font(.headline)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(details.tags) { tag in
                        Text(tag.name)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(.secondary.opacity(0.15))
                            .clipShape(Capsule())
                    }
                }
            }
        }
    }
    
    private var headerBar: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.title3)
                    .padding(8)
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
            }

            Spacer()

            Text(wallpaper.id)
                .font(.headline)

            Spacer()
        }
    }
    
    private var fullImage: some View {
        AsyncImage(
            url: wallpaper.fullURL,
            transaction: Transaction(animation: .easeInOut)
        ) { phase in
            switch phase {

            case .success(let image):
                image
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .onTapGesture {
                        showFullscreenImage = true
                    }
                    .contextMenu {
                        imageActions
                    }

            case .failure:
                failedView
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            reloadToken = UUID()
                        }
                    }

            default:
                ProgressView()
                    .frame(height: 300)
            }
        }
        // 🔑 THIS forces reload
        .id(reloadToken)
        .fullScreenCover(isPresented: $showFullscreenImage) {
            ShopImageFullscreenView(imageURL: wallpaper.fullURL)
        }
    }

    private var failedView: some View {
        VStack(spacing: 12) {
            Color.black
                .overlay(
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.largeTitle)
                        .foregroundColor(.yellow)
                )
                .frame(height: 300)
                .clipShape(RoundedRectangle(cornerRadius: 12))

            Button {
                HapticManager.impact(.medium)
                reloadToken = UUID()   // 🔁 FORCE reload
            } label: {
                Label("Reload Image", systemImage: "arrow.clockwise")
                    .font(.headline)
            }
        }
    }

    private var imageActions: some View {
        Group {
            Button {
                Task {
                    await ImageSaveManager.save(
                        imageURL: wallpaper.fullURL,
                        status: { newStatus in
                            downloadStatus = newStatus
                        }
                    )
                }
            } label: {
                Label("Save to Photos", systemImage: "photo")
            }

            Button {
                HapticManager.impact(.medium)
                downloadStatus = .downloading

                Task {
                    do {
                        tempDownloadURL = try await DownloadManager.shared.download(
                            from: wallpaper.fullURL
                        )
                        showSavePicker = true
                    } catch {
                        downloadStatus = .failed("Download failed")
                    }
                }
            } label: {
                Label("Download File", systemImage: "arrow.down.circle")
            }

            Button {
                ShareManager.share(url: wallpaper.fullURL)
            } label: {
                Label("Share", systemImage: "square.and.arrow.up")
            }

            Button {
                UIPasteboard.general.url = wallpaper.fullURL
            } label: {
                Label("Copy Link", systemImage: "link")
            }
        }
    }


    private var metaSection: some View {
        HStack {
            Label("\(wallpaper.views)", systemImage: "eye")
            Spacer()
            Label("\(wallpaper.favorites)", systemImage: "heart")
            Spacer()
            Text("\(wallpaper.width)x\(wallpaper.height)")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .font(.caption)
    }

    private func uploaderSection(
        _ details: ShopWallpaperDetails
    ) -> some View {
        HStack(spacing: 8) {
            if let avatar = details.uploaderAvatarURL {
                AsyncImage(url: avatar) { image in
                    image.resizable()
                } placeholder: {
                    Circle().fill(.secondary.opacity(0.3))
                }
                .frame(width: 32, height: 32)
                .clipShape(Circle())
            }

            Text(details.uploaderName)
                .font(.headline)

            Spacer()
        }
    }
    
    private func tagsSection(_ details: ShopWallpaperDetails) -> some View {
        VStack(alignment: .leading, spacing: 12) {

            Text("Tags")
                .font(.headline)

            LazyVGrid(
                columns: [
                    GridItem(.adaptive(minimum: 90), spacing: 8)
                ],
                alignment: .leading,
                spacing: 8
            ) {
                ForEach(details.tags) { tag in
                    Button {
                        handleTagTap(tag)
                    } label: {
                        Text(tag.name)
                            .font(.caption)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(.secondary.opacity(0.15))
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }


}

struct TagWrapView: View {
    let tags: [ShopTag]
    let onTap: (ShopTag) -> Void

    var body: some View {
        TagFlowLayout(tags: tags) { tag in
            Button {
                onTap(tag)
            } label: {
                Text(tag.name)
                    .font(.caption)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(.secondary.opacity(0.15))
                    .clipShape(Capsule())
            }
        }
    }
}


struct TagFlowLayout: View {
    let tags: [ShopTag]
    let onTap: (ShopTag) -> Void

    @State private var totalHeight: CGFloat = .zero

    var body: some View {
        VStack {
            GeometryReader { geo in
                generateContent(in: geo)
            }
        }
        .frame(height: totalHeight)
    }

    private func generateContent(in geo: GeometryProxy) -> some View {
        var x: CGFloat = 0
        var y: CGFloat = 0

        return ZStack(alignment: .topLeading) {
            ForEach(tags) { tag in
                tagView(tag)
                    .alignmentGuide(.leading) { d in
                        if x + d.width > geo.size.width {
                            x = 0
                            y += d.height
                        }
                        let result = x
                        x += d.width
                        return result
                    }
                    .alignmentGuide(.top) { _ in
                        let result = y
                        return result
                    }
            }
        }
        .background(
            GeometryReader { geo in
                Color.clear
                    .onAppear {
                        totalHeight = geo.size.height
                    }
                    .onChange(of: geo.size.height) { newValue in
                        totalHeight = newValue
                    }
            }
        )
    }

    private func tagView(_ tag: ShopTag) -> some View {
        Button {
            onTap(tag)
        } label: {
            Text(tag.name)
                .font(.caption)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(.secondary.opacity(0.15))
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}
