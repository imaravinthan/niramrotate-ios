//
//  BundleListRow.swift
//  niramrotate
//
//  Created by aravinthan.selvaraj on 14/12/25.
//

import SwiftUI

struct BundleListRow: View {
    let bundle: ImageBundle

    var body: some View {
        VStack(alignment: .leading) {
            Text(bundle.name)
                .font(.headline)
            Text("\(bundle.imageCount) images")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}
