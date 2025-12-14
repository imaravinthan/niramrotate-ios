//
//  BundleGridCard.swift
//  niramrotate
//
//  Created by aravinthan.selvaraj on 14/12/25.
//

import SwiftUI

struct BundleGridCard: View {
    let bundle: ImageBundle

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.3))
                .frame(height: 120)
                .overlay(
                    Text("\(bundle.imageCount)")
                        .font(.largeTitle.bold())
                )

            Text(bundle.name)
                .font(.headline)

            Text("\(bundle.imageCount) images")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}
