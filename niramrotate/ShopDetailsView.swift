//
//  ShopDetailsView.swift
//  niramrotate
//
//  Created by aravinthan.selvaraj on 16/12/25.
//
import SwiftUI

struct ShopDetailsView: View {

    let wallpaper: ShopWallpaper
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 16) {

            // Drag handle
            Capsule()
                .fill(.secondary.opacity(0.4))
                .frame(width: 40, height: 5)
                .padding(.top, 8)

            Text("Details")
                .font(.title3.bold())

            Divider()

            ScrollView {
                VStack(spacing: 12) {
                    infoRow("ID", wallpaper.id, "number")
                    infoRow("Resolution", "\(wallpaper.width)x\(wallpaper.height)", "rectangle.expand.vertical")
                    infoRow("Ratio", wallpaper.ratio, "aspectratio")
//                    infoRow("Category", wallpaper.category.capitalized, "tag")
//                    infoRow("Purity", wallpaper.purity.uppercased(), "eye.slash")
//                    infoRow("Views", "\(wallpaper.views)", "eye")
//                    infoRow("Favorites", "\(wallpaper.favorites)", "heart")
                    infoRow("File Size", wallpaper.fileSizeMB, "externaldrive")
                    infoRow("File Type", wallpaper.fileType, "doc")
                    infoRow("Created", wallpaper.createdAt, "calendar")
                }
                .padding(.horizontal)
            }

            Divider()

            Button {
                UIApplication.shared.open(wallpaper.webURL)
            } label: {
                Label("Open in Browser", systemImage: "safari")
                    .font(.headline)
            }
            .padding(.bottom)
        }
        .background(.ultraThinMaterial)
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }

    private func infoRow(
        _ title: String,
        _ value: String,
        _ icon: String
    ) -> some View {
        HStack {
            Label(title, systemImage: icon)
                .foregroundStyle(.secondary)

            Spacer()

            Text(value)
                .font(.callout.weight(.semibold))
                .multilineTextAlignment(.trailing)
        }
    }
}
