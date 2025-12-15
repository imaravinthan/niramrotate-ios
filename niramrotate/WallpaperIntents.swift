//
//  WallpaperIntents.swift
//  niramrotate
//
//  Created by aravinthan.selvaraj on 14/12/25.
//

import AppIntents
import Foundation
import UIKit
import ExtensionFoundation

enum WallpaperTarget: String, AppEnum {
    case lock
    case home
    case both

    static var typeDisplayRepresentation =
        TypeDisplayRepresentation(name: "Wallpaper Target")

    static var caseDisplayRepresentations: [Self: DisplayRepresentation] = [
        .lock: .init(title: "Lock Screen"),
        .home: .init(title: "Home Screen"),
        .both: .init(title: "Both")
    ]
}


struct WallyIntents: AppIntentsExtension {}


struct ImageBundleEntity: AppEntity, Identifiable, Hashable {

    static var typeDisplayRepresentation =
        TypeDisplayRepresentation(name: "Wallpaper Bundle")

    static var defaultQuery = ImageBundleQuery()

    let id: String      // UUID string
    let name: String

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(name)")
    }

    init(bundle: ImageBundle) {
        self.id = bundle.id.uuidString
        self.name = bundle.name
    }
}

struct ImageBundleQuery: EntityQuery {
    
    func entities(for identifiers: [String]) async throws -> [ImageBundleEntity] {
        ImageBundleStore.shared
            .loadAllBundles()
            .filter { identifiers.contains($0.id.uuidString) }
            .map(ImageBundleEntity.init)
    }

    func suggestedEntities() async throws -> [ImageBundleEntity] {
        ImageBundleStore.shared
            .loadAllBundles()
            .map(ImageBundleEntity.init)
    }
}


struct GetNextWallpaperIntent: AppIntent {

    static var title: LocalizedStringResource = "Get Next Wallpaper"
    static var description =
        IntentDescription("Returns the next wallpaper image from a bundle")

    @Parameter(title: "Bundle")
    var bundle: ImageBundleEntity
    
    @Parameter(title: "Apply To")
    var target: WallpaperTarget


    func perform() async throws -> some IntentResult & ReturnsValue<IntentFile> {

        // 1. Resolve bundle model
        guard let bundleModel = ImageBundleStore.shared
            .loadAllBundles()
            .first(where: { $0.id.uuidString == bundle.id })
        else {
            throw NSError(domain: "Wally", code: 1)
        }

        // 2. Get next image (NO repeats)
        let data = try WallpaperRotationEngine.shared
            .nextImageData(forID: bundleModel.id)

        // 3. Write temp file
        let url = FileManager.default
            .temporaryDirectory
            .appendingPathComponent("wallpaper.jpg")

        try data.write(to: url, options: Data.WritingOptions.atomic)

        // 4. Return file to Shortcuts
        return .result(value: IntentFile(fileURL: url))
    }

}


