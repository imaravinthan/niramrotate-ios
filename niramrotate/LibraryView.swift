//
//  LibraryView.swift
//  niramrotate
//
//  Created by aravinthan.selvaraj on 14/12/25.
//

import SwiftUI

struct LibraryView: View {
    @StateObject private var vm = LibraryViewModel()

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Library")
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Menu {
                            Picker("Sort", selection: $vm.sortOption) {
                                ForEach(LibrarySortOption.allCases, id: \.self) {
                                    Text($0.rawValue)
                                }
                            }
                            .onChange(of: vm.sortOption) { _, _ in
                                vm.applySort()
                            }
                        } label: {
                            Image(systemName: "arrow.up.arrow.down")
                        }
                    }

                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            vm.isGrid.toggle()
                        } label: {
                            Image(systemName: vm.isGrid ? "list.bullet" : "square.grid.2x2")
                        }
                    }
                }
                .onAppear {
                    vm.loadBundles()
                }
        }
    }

    @ViewBuilder
    private var content: some View {
        if vm.isGrid {
            ScrollView {
                LazyVStack(spacing: 20) {
                    ForEach(vm.bundles) { bundle in
                        NavigationLink {
                            BundleViewerView(bundle: bundle)
                        } label: {
                            BundleWallpaperCard(
                                bundle: bundle,
                                image: vm.wallpaper(for: bundle)
                            )
                        }
                    }
                }
                .padding()
            }
        } else {
            List(vm.bundles) { bundle in
                BundleListRow(bundle: bundle)
            }
        }
    }
}
