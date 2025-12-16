//
//  LibraryView.swift
//  niramrotate
//
//  Created by aravinthan.selvaraj on 14/12/25.
//

import SwiftUI

struct LibraryView: View {
    @StateObject private var vm = LibraryViewModel()

    @StateObject private var settings = AppSettings.shared
    @State private var showSearch = false
    
    var body: some View {
        NavigationStack {
            List {

                // Telegram-style Archived row
                if settings.pinarchiveEnabled && !vm.archived.isEmpty {
                    Section {
                        NavigationLink {
                            ArchivedLibraryView(vm: vm)
                        } label: {
                            HStack {
                                Image(systemName: "archivebox.fill")
                                Text("Archived")
                                Spacer()
                                Text("\(vm.archived.count)")
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }

                // Active bundles
                Section {
                    ForEach(vm.displayBundles) { bundle in
                        BundleRow(bundle: bundle)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Library")
            .searchable(
                text: $vm.searchText,
                isPresented: $showSearch,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: "Search bundles"
            )
            .toolbar { toolbarContent }
            .refreshable { vm.loadBundles() }
            .onAppear { vm.loadBundles() }
        }
        .environmentObject(vm)
        .environmentObject(settings)
    }

    // MARK: - Toolbar
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {

        ToolbarItem(placement: .topBarLeading) {
            if vm.isSelectionMode {
                Button("Cancel") {
                    vm.clearSelection()
                }
            } else {
                Menu {
                    Picker("Sort", selection: $vm.sortOption) {
                        ForEach(LibrarySortOption.allCases, id: \.self) {
                            Text($0.rawValue)
                        }
                    }
                } label: {
                    Image(systemName: "arrow.up.arrow.down")
                }
                
                Button {
                    showSearch.toggle()
                } label: {
                    Image(systemName: "magnifyingglass")
                }
            }
        }

        ToolbarItem(placement: .topBarTrailing) {
            if vm.isSelectionMode {
                HStack {
                    Button { vm.bulkArchive() } label: {
                        Image(systemName: "archivebox.fill")
                    }
                    Button { vm.bulkDownload() } label: {
                        Image(systemName: "arrow.down.to.line")
                    }
                    Button(role: .destructive) {
                        vm.bulkDelete()
                    } label: {
                        Image(systemName: "trash.fill")
                    }
                }
            } else {
                Button {
                    vm.isSelectionMode = true
                } label: {
                    Image(systemName: "checkmark.circle")
                }
            }
        }
    }
}
