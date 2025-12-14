//
//  CreateBundleView.swift
//  niramrotate
//
//  Created by aravinthan.selvaraj on 14/12/25.
//

import SwiftUI
import PhotosUI
import Combine

struct CreateBundleView: View {

    @Environment(\.dismiss) private var dismiss

    @StateObject private var vm = CreateBundleViewModel()

    private let gridColumns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

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

                    if vm.previewImages.count > 0 {
                        Text("\(vm.previewImages.count) images selected")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }

                // MARK: - Preview Grid
                Section("Preview (\(vm.previewImages.count))") {
                    if vm.previewImages.isEmpty {
                        Text("No images selected")
                            .foregroundStyle(.secondary)
                    } else {
                        LazyVGrid(
                            columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3),
                            spacing: 12
                        ) {
                            ForEach(vm.previewImages.indices, id: \.self) { index in
                                ZStack(alignment: .topTrailing) {
                                    Image(uiImage: vm.previewImages[index])
                                        .resizable()
                                        .scaledToFill()
                                        .frame(height: 110)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                        .clipped()

                                    Button {
                                        vm.removeImage(at: index)
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
                if let error = vm.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                }
            }
            .navigationTitle("Create Bundle")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Task {
                            let success = await vm.createBundle()
                            if success {
                                dismiss()
                            }
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
        }
    }
}

