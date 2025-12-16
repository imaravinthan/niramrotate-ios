//
//  BundleRow.swift
//  niramrotate
//
//  Created by aravinthan.selvaraj on 16/12/25.
//

import SwiftUI

struct BundleRow: View {
    let bundle: ImageBundle
    @EnvironmentObject private var vm: LibraryViewModel

    var body: some View {
        ZStack {
            if vm.isSelectionMode {
                selectionRow
            } else {
                navigationRow
            }
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            if !vm.isSelectionMode {
                swipeActions
            }
        }
    }

    // MARK: - Normal mode
    private var navigationRow: some View {
        NavigationLink {
            BundleViewerView(bundle: bundle)
                .toolbar(.hidden, for: .tabBar)
        } label: {
            BundleLibraryRow(bundle: bundle)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Selection mode
    private var selectionRow: some View {
        HStack {
            Button {
                vm.toggleSelection(bundle)
            } label: {
                Image(systemName:
                        vm.selectedIDs.contains(bundle.id)
                        ? "checkmark.circle.fill"
                        : "circle"
                )
            }
            .buttonStyle(.plain)

            BundleLibraryRow(bundle: bundle)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            vm.toggleSelection(bundle)
        }
        .background(
            vm.selectedIDs.contains(bundle.id)
            ? Color.blue.opacity(0.15)
            : Color.clear
        )
    }

    // MARK: - Swipe actions
    private var swipeActions: some View {
        Group {
            Button(role: .destructive) {
                vm.delete(bundle)
            } label: {
                Image(systemName: "trash.fill")
            }

            Button {
                vm.archive(bundle)
            } label: {
                Image(systemName: "archivebox.fill")
            }
            .tint(.gray)

            Button {
                vm.download(bundle)
            } label: {
                Image(systemName: "arrow.down.to.line")
            }
            .tint(.blue)
        }
    }
}
