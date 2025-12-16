//
//  CreateBundleView.swift
//  niramrotate
//
//  Created by aravinthan.selvaraj on 14/12/25.
//

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
                }

                // MARK: - Image Picker
                Section {
                    PhotosPicker(
                        selection: $vm.selectedItems,
                        matching: .images
                    ) {
                        Label("Add Images", systemImage: "photo.on.rectangle")
                    }
                    .onChange(of: vm.selectedItems) {
                        Task { await vm.appendPickedItems() }
                    }

                    if !vm.previews.isEmpty {
                        Text("\(vm.previews.count) images selected")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
                

                // MARK: - Preview Grid
                Section("Preview (\(vm.previews.count))") {
                    if vm.previews.isEmpty {
                        Text("No images selected")
                            .foregroundStyle(.secondary)
                    } else {
                        LazyVGrid(
                            columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3),
                            spacing: 12
                        ) {
                            ForEach(vm.previews) { item in
                                ZStack(alignment: .topTrailing) {
                                    Image(uiImage: item.image)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(height: 110)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                        .clipped()

                                    Button {
                                        vm.removeImage(id: item.id)
                                    } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundStyle(.white)
                                            .background(.black.opacity(0.6))
                                            .clipShape(Circle())
                                    }
                                    .padding(6)
                                }
                            }
                        }

                        Button("Clear All", role: .destructive) {
                            vm.clearAll()
                        }
                    }
                }
            }
            .navigationTitle("Create Bundle")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Task {
                            await vm.createBundle()
                        }
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
            .alert(
                vm.creationSucceeded ? "Success" : "Error",
                isPresented: $vm.showResultAlert
            ) {
                if vm.creationSucceeded {
                    Button("Done") {
                        vm.clearAll()
                        dismiss()
                    }
                    .tint(.green)
                } else {
                    Button("OK", role: .cancel) {}
                }
            } message: {
                Text(vm.resultMessage)
            }
        }
    }
}
