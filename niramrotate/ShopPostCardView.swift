//
//  ShopPostCardView.swift
//  niramrotate
//
//  Created by aravinthan.selvaraj on 19/12/25.
//


import SwiftUI

#Preview("Shop view"){
    ShopPostCardView(
        wallpaper: .previewAPIKEY,
        onOptionsTap: { _ in
               // no-op for preview
        },
        onTagTap: { _ in
            // no-op for preview
        }
    ) 
}

enum ShopPostAction {
    case download
    case share
    case fullscreen
    case details
}

struct ShopPostCardView: View {

    let wallpaper: ShopWallpaper
    let onOptionsTap: (ShopWallpaper) -> Void
    let onTagTap: (String) -> Void

    @StateObject private var prefs = ShopPreferences.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {

            titleRow
            headerRow
            imageSection
            preFooter

            if prefs.hasKey {
                tagsFooter
            }
        }
        .padding()
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal)
    }
    
    private var cardHeight: CGFloat {
        let screenWidth = UIScreen.main.bounds.width - 32
        let aspect = CGFloat(wallpaper.height) / CGFloat(wallpaper.width)
        let clamped = min(max(aspect, 0.7), 1.8)
        return screenWidth * clamped
    }
    
    private var titleRow: some View {
        HStack {
            Text(wallpaper.id)
                .font(.headline)
                .lineLimit(1)

            Spacer()

            if prefs.hasKey {
                Text(wallpaper.uploader ?? "")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Button {
                onOptionsTap(wallpaper)
            } label: {
                Image(systemName: "ellipsis")
            }
        }
    }
    
    private var headerRow: some View {
        HStack(spacing: 6) {
            Image(systemName: categorySymbol)
                .foregroundStyle(.secondary)

            Text(wallpaper.category.capitalized)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private var categorySymbol: String {
        switch wallpaper.category.lowercased() {
        case "anime": return "sparkles"
        case "people": return "person.fill"
        default: return "photo"
        }
    }
    
    private var imageSection: some View {
        ZStack(alignment: .topLeading) {

            ProgressiveImageView(
                previewURL: wallpaper.previewURL,
                fullURL: wallpaper.fullURL,
                wallpaper: wallpaper,
                height: cardHeight
            )

            if wallpaper.isNSFW {
                Text("NSFW")
                    .font(.caption2.bold())
                    .foregroundColor(.red)
                    .padding(6)
                    .background(.black.opacity(0.7))
                    .clipShape(Capsule())
                    .padding(8)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private var preFooter: some View {
        HStack {
            Label("\(wallpaper.views)", systemImage: "eye")
            Spacer()
            Label("\(wallpaper.favorites)", systemImage: "heart")
        }
        .font(.caption)
        .foregroundStyle(.secondary)
    }
    
    private var tagsFooter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(wallpaper.tags ?? []) { tag in
                    Button {
                        onTagTap(tag.name)
                    } label: {
                        Text(tag.name)
                            .font(.caption2)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(.secondary.opacity(0.15))
                            .clipShape(Capsule())
                    }
                }
            }
        }
    }

}
