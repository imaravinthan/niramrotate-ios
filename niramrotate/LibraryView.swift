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
                    ToolbarItem(placement: .topBarTrailing) {
                        NavigationLink {
                            ArchivedLibraryView(vm: vm)
                        } label: {
                            Image(systemName: "archivebox")
                        }
                    }

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

//                    ToolbarItem(placement: .topBarTrailing) {
//                        Button {
//                            vm.isGrid.toggle()
//                        } label: {
//                            Image(systemName: vm.isGrid ? "list.bullet" : "square.grid.2x2")
//                        }
//                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            vm.toggleSelectAll()
                        } label: {
                            Image(systemName: vm.isAllSelected ? "checkmark.circle.fill" : "checkmark.circle")
                        }
                    }

                }
                .onAppear {
                    vm.loadBundles()
                }
//                .navigationDestination(isPresented: $vm.showArchived) {
//                    ArchivedLibraryView(vm: vm)
//                }
//                .refreshable {
//                    vm.showArchived = true
//                }
        }
    }
    
    @ViewBuilder
    private var content: some View {
        if vm.bundles.isEmpty {
            ContentUnavailableView(
                "No wallpapers",
                systemImage: "photo",
                description: Text("Create a bundle to get started")
            )
        } else {
//            ScrollView {
//                LazyVStack(spacing: 16) {
//                    ForEach(vm.bundles) { bundle in
//                        NavigationLink {
//                            BundleViewerView(bundle: bundle)
//                                .toolbar(.hidden, for: .tabBar)
//                        } label: {
//                            BundleLibraryRow(bundle: bundle)
//                        }
//                    }
//                }
//                .padding()
//            }
            List {
                ForEach(vm.active) { bundle in
                    NavigationLink {
                        BundleViewerView(bundle: bundle)
                            .toolbar(.hidden, for: .tabBar)
                    } label: {
                        BundleLibraryRow(bundle: bundle)
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {

                        // DELETE
                        Button(role: .destructive) {
                            vm.delete(bundle)
                        } label: {
                            Image(systemName: "trash.fill")
                        }

                        // ARCHIVE
                        Button {
                            vm.archive(bundle)
                        } label: {
                            Image(systemName: "archivebox.fill")
                        }
                        .tint(.gray)

                        // DOWNLOAD
                        Button {
                            vm.download(bundle)
                        } label: {
                            Image(systemName: "arrow.down.to.line")
                        }
                        .tint(.blue)
                    }
                }
            }
            .listStyle(.plain)
            .refreshable {
                vm.loadBundles()
            }
        }
    }


}
