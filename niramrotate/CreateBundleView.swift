//
//  CreateBundleView.swift
//  niramrotate
//
//  Created by aravinthan.selvaraj on 14/12/25.
//

//import SwiftUI
//import PhotosUI
//
//
//struct CreateBundleView: View {
//
//    @Environment(\.dismiss) private var dismiss
//    @StateObject private var vm = CreateBundleViewModel()
//
//    var body: some View {
//        NavigationStack {
//            Form {
//
//                // MARK: - Bundle name
//                Section("Bundle Name") {
//                    TextField("e.g. Work Focus", text: $vm.bundleName)
//                        .textInputAutocapitalization(.words)
//                }
//
//                // MARK: - Image pager
//                Section("Images") {
//                    if vm.previews.isEmpty {
//                        Button {
//                            vm.showPicker = true
//                        } label: {
//                            Label("Add Images", systemImage: "photo.on.rectangle")
//                        }
//                    } else {
//                        TabView(selection: $vm.currentIndex) {
//                            ForEach(vm.previews.indices, id: \.self) { index in
//                                Image(uiImage: vm.previews[index].image)
//                                    .resizable()
//                                    .scaledToFit()
//                                    .tag(index)
//                            }
//                        }
//                        .frame(height: 280)
//                        .tabViewStyle(.page(indexDisplayMode: .automatic))
//
//                        Text("\(vm.previews.count) images selected")
//                            .font(.footnote)
//                            .foregroundStyle(.secondary)
//                    }
//                }
//
//                // MARK: - NSFW consent
//                Section("Content") {
//                    Toggle(
//                        "This bundle contains sensitive / NSFW content",
//                        isOn: $vm.isNSFW
//                    )
//                }
//            }
//            .navigationTitle("Create Bundle")
//            .toolbar {
//
//                // Cancel
//                ToolbarItem(placement: .topBarLeading) {
//                    Button("Cancel") {
//                        dismiss()
//                    }
//                }
//
//                // Create
//                ToolbarItem(placement: .topBarTrailing) {
//                    Button {
//                        Task { await vm.createBundle() }
//                    } label: {
//                        if vm.isCreating {
//                            ProgressView()
//                        } else {
//                            Text("Create")
//                        }
//                    }
//                    .disabled(!vm.canCreate)
//                }
//            }
//
//            // Delete / Add overlays (Reddit-style)
//            .overlay(alignment: .topTrailing) {
//                if !vm.previews.isEmpty {
//                    Button {
//                        vm.showDeleteSheet = true
//                    } label: {
//                        Image(systemName: "xmark.circle.fill")
//                            .font(.title)
//                            .foregroundStyle(.white)
//                            .background(.black.opacity(0.6))
//                            .clipShape(Circle())
//                            .padding()
//                    }
//                }
//            }
//            .overlay(alignment: .bottomTrailing) {
//                if !vm.previews.isEmpty {
//                    Button {
//                        vm.showPicker = true
//                    } label: {
//                        Label("Add", systemImage: "photo.on.rectangle")
//                            .padding(.horizontal, 14)
//                            .padding(.vertical, 10)
//                            .background(.ultraThinMaterial)
//                            .clipShape(Capsule())
//                            .padding()
//                    }
//                }
//            }
//
//            // Picker
//            .photosPicker(
//                isPresented: $vm.showPicker,
//                selection: $vm.selectedItems,
//                matching: .images
//            )
//            .onChange(of: vm.selectedItems) {
//                Task { await vm.appendPickedItems() }
//            }
//
//            // Delete actions
//            .confirmationDialog(
//                "Remove image",
//                isPresented: $vm.showDeleteSheet
//            ) {
//                Button("Delete current image", role: .destructive) {
//                    vm.removeCurrentImage()
//                }
//
//                Button("Delete all images", role: .destructive) {
//                    vm.clearAll()
//                }
//
//                Button("Cancel", role: .cancel) {}
//            }
//
//            // Result alert
//            .alert(
//                vm.creationSucceeded ? "Success" : "Error",
//                isPresented: $vm.showResultAlert
//            ) {
//                if vm.creationSucceeded {
//                    Button("Done") {
//                        dismiss()
//                    }
//                } else {
//                    Button("OK", role: .cancel) {}
//                }
//            } message: {
//                Text(vm.resultMessage)
//            }
//        }
//    }
//}

import SwiftUI
import PhotosUI

struct CreateBundleView: View {

    @Environment(\.dismiss) private var dismiss
    @StateObject private var vm = CreateBundleViewModel()

    var body: some View {
        NavigationStack {
            Form {

                // MARK: - Bundle Name
                Section("Bundle Name") {
                    TextField("e.g. Work Focus", text: $vm.bundleName)
                        .textInputAutocapitalization(.words)

                    if vm.isDuplicateName {
                        Text("A bundle with this name already exists.")
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                }


                // MARK: - Images (Reddit-style)
                Section("Images") {

                    if vm.previews.isEmpty {
                        Button {
                            vm.showPicker = true
                        } label: {
                            Label("Add Images", systemImage: "photo.on.rectangle")
                        }
                    } else {

                        ZStack {

                            // Image pager
                            TabView(selection: $vm.currentIndex) {
                                ForEach(vm.previews.indices, id: \.self) { index in
                                    Image(uiImage: vm.previews[index].image)
                                        .resizable()
                                        .scaledToFit()
                                        .tag(index)
                                }
                            }
                            .tabViewStyle(.page(indexDisplayMode: .automatic))

                            // ❌ Delete (top-right of image only)
                            VStack {
                                HStack {
                                    Spacer()
                                    Button {
                                        vm.showDeleteSheet = true
                                    } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .font(.title)
                                            .foregroundStyle(.white)
                                            .background(.black.opacity(0.6))
                                            .clipShape(Circle())
                                            .contentShape(Circle())
                                            .onTapGesture {
                                                vm.showDeleteSheet = true
                                            }
                                            .allowsHitTesting(true)
                                    }
                                }
                                Spacer()
                            }
                            .padding(12)

                            // ➕ Add (bottom-right of image only)
                            VStack {
                                Spacer()
                                HStack {
                                    Spacer()
                                    Button {
                                        vm.showPicker = true
                                    } label: {
                                        Label("Add", systemImage: "photo.on.rectangle")
                                            .padding(.horizontal, 14)
                                            .padding(.vertical, 10)
                                            .background(.ultraThinMaterial)
                                            .clipShape(Capsule())
                                    }
                                }
                            }
                            .padding(12)
                        }
                        .frame(height: 280)

                        Text("\(vm.previews.count) images selected")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }

                // MARK: - NSFW Consent
                Section("Content") {
                    Toggle(
                        "This bundle contains sensitive / NSFW content",
                        isOn: $vm.isNSFW
                    )
                }
            }
            .navigationTitle("Create Bundle")
            .toolbar {

                // Cancel
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                // Create
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Task { await vm.createBundle() }
                    } label: {
                        if vm.isCreating {
                            ProgressView()
                        } else {
                            Text("Create")
                        }
                    }
                    .disabled(!vm.canCreate)
                }
            }

            // MARK: - Photos Picker
            .photosPicker(
                isPresented: $vm.showPicker,
                selection: $vm.selectedItems,
                matching: .images
            )
            .onChange(of: vm.selectedItems) {
                Task { await vm.appendPickedItems() }
            }

            // MARK: - Delete Actions
            .confirmationDialog(
                "Remove image",
                isPresented: $vm.showDeleteSheet
            ) {
                Button("Delete current image", role: .destructive) {
                    vm.removeCurrentImage()
                }

                Button("Delete all images", role: .destructive) {
                    vm.clearAll()
                }

                Button("Cancel", role: .cancel) {}
            }

            // MARK: - Result Alert
            .alert(
                vm.creationSucceeded ? "Success" : "Error",
                isPresented: $vm.showResultAlert
            ) {
                if vm.creationSucceeded {
                    Button("Done") {
                        dismiss()
                    }
                } else {
                    Button("OK", role: .cancel) {}
                }
            } message: {
                Text(vm.resultMessage)
            }
        }
    }
}
