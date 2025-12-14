//
//  ShuffleWallpaperIntent.swift
//  niramrotate
//
//  Created by aravinthan.selvaraj on 14/12/25.
//
import AppIntents
import UniformTypeIdentifiers

struct ShuffleWallpaperIntent: AppIntent {

    static var title: LocalizedStringResource = "Shuffle Wallpaper"

    @Parameter(title: "Bundle")
    var bundle: ImageBundleEntity

    func perform() async throws -> some ReturnsValue<IntentFile> {

        let data = try WallpaperManager.shared
            .nextWallpaper(for: bundle.id)

        let file = IntentFile(
            data: data,
            filename: "wallpaper.jpg",
            type: .image
        )

        return .result(value: file)
    }
}
