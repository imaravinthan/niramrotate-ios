//
//  ArchivedLibraryView.swift
//  niramrotate
//
//  Created by aravinthan.selvaraj on 16/12/25.
//

//import SwiftUI
//
//struct ArchivedLibraryView: View {
//
//    @StateObject private var vm: LibraryViewModel
//
//    init(vm: LibraryViewModel) {
//        self.vm = vm
//    }
//
//    var body: some View {
//        List {
//            ForEach(vm.archived, id: \.id) { bundle in
//                BundleLibraryRow(bundle: bundle)
//                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
//
//                        // UNARCHIVE
//                        Button {
//                            vm.unarchive(bundle)
//                        } label: {
//                            Image(systemName: "arrow.uturn.left")
//                        }
//                        .tint(.green)
//
//                        // DELETE
//                        Button(role: .destructive) {
//                            vm.delete(bundle)
//                        } label: {
//                            Image(systemName: "trash.fill")
//                        }
//                    }
//            }
//        }
//        .navigationTitle("Archived")
//        .listStyle(.plain)
//    }
////}
//import SwiftUI
//
//struct ArchivedLibraryView: View {
//
//    @ObservedObject var vm: LibraryViewModel
//
//    var body: some View {
//        List {
//            ForEach(vm.archived) { bundle in
//                BundleLibraryRow(bundle: bundle)
//                    .swipeActions {
//
//                        Button {
//                            vm.unarchive(bundle)
//                        } label: {
//                            Image(systemName: "arrow.uturn.left")
//                        }
//                        .tint(.green)
//
//                        Button(role: .destructive) {
//                            vm.delete(bundle)
//                        } label: {
//                            Image(systemName: "trash.fill")
//                        }
//                    }
//            }
//        }
//        .navigationTitle("Archived")
//    }
//}

import SwiftUI

struct ArchivedLibraryView: View {
    @ObservedObject var vm: LibraryViewModel

    var body: some View {
        List {
            ForEach(vm.archived) { bundle in
                BundleLibraryRow(bundle: bundle)
                    .swipeActions {
                        Button {
                            vm.unarchive(bundle)
                        } label: {
                            Image(systemName: "arrow.uturn.left")
                        }
                        .tint(.blue)
                    }
            }
        }
        .navigationTitle("Archived")
        .listStyle(.insetGrouped)
        .onAppear { vm.loadBundles() }
    }
}
