//
//  BundleListView.swift
//  niramrotate
//
//  Created by aravinthan.selvaraj on 14/12/25.
//

import SwiftUI

struct BundleListView: View {

    @StateObject private var vm = BundleListViewModel()

    var body: some View {
        NavigationStack {
            List(vm.bundles) { bundle in
                VStack(alignment: .leading, spacing: 4) {
                    Text(bundle.name)
                        .font(.headline)

                    Text("\(bundle.imageCount) images")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    Text(bundle.createdAt.formatted(date: .abbreviated, time: .shortened))
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .navigationTitle("Bundles")
            .onAppear {
                vm.load()
            }
        }
    }
}
