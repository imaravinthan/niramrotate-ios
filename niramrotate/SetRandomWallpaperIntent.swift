//
//  SetRandomWallpaperIntent.swift
//  niramrotate
//
//  Created by aravinthan.selvaraj on 14/12/25.
//

import AppIntents
import UIKit

struct SetRandomWallpaperIntent: AppIntent {

    static var title: LocalizedStringResource =
        "Set Random Wallpaper"

    static var description =
        IntentDescription("Sets a random wallpaper from a selected bundle")

    @Parameter(title: "Bundle")
    var bundleName: String

    static var parameterSummary: some ParameterSummary {
        Summary("Set random wallpaper from \(\.$bundleName)")
    }

    func perform() async throws -> some IntentResult {
        try WallpaperService.setRandomWallpaper(bundleName: bundleName)
        return .result()
    }
}
