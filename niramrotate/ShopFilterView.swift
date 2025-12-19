//
//  ShopFilterView.swift
//  niramrotate
//
//  Created by aravinthan.selvaraj on 17/12/25.
//


import SwiftUI

struct ShopFilterView: View {

    @Binding var filters: ShopFilters
    let onApply: () -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {

                Section("Sorting") {
                    Picker("Order", selection: $filters.sorting) {
                        ForEach(ShopFilters.Sorting.allCases, id: \.self) {
                            Text($0.rawValue.capitalized)
                        }
                    }
                }

                Section("Categories") {
                    ForEach(ShopFilters.Category.allCases, id: \.self) { cat in
                        Toggle(label(for: cat), isOn: binding(for: cat))
                    }
                }

                Section("Content") {
                    ForEach(availablePurityOptions, id: \.self) { mode in
                        HStack {
                            Text(mode.title)
                            Spacer()
                            if filters.purity == mode {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(.blue)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            filters.purity = mode
                        }
                    }
                }


                Section("Aspect Ratio") {
                    ForEach(ShopFilters.AspectRatio.allCases, id: \.self) { ratio in
                        Toggle(
                            ratio.rawValue,
                            isOn: binding(for: ratio)
                        )
                    }
                }

                Section("Preferences") {
                    Toggle("Remember Seen Wallpapers", isOn: $filters.rememberSeen)
                }
            }
            .navigationTitle("Filters")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Apply") {
                        onApply()
                        dismiss()
                    }
                }
            }
        }
    }

    // MARK: - Bindings

    private func binding(for category: ShopFilters.Category) -> Binding<Bool> {
        Binding(
            get: {
                filters.categories.contains(category)
            },
            set: { enabled in
                if enabled {
                    filters.categories.insert(category)
                } else {
                    filters.categories.remove(category)
                }
            }
        )
    }


    private func binding(for ratio: ShopFilters.AspectRatio) -> Binding<Bool> {
        Binding(
            get: {
                filters.aspectRatios.contains(ratio)
            },
            set: { enabled in
                if enabled {
                    filters.aspectRatios.insert(ratio)
                } else {
                    filters.aspectRatios.remove(ratio)
                }
            }
        )
    }

    private var availablePurityOptions: [ShopFilters.PurityMode] {
        if ShopPreferences.shared.hasWallhavenKey {
            return ShopFilters.PurityMode.allCases
        } else {
            return [.sfw, .sketchy]
        }
    }

    private func label(for category: ShopFilters.Category) -> String {
        switch category {
        case .general: return "General"
        case .anime:   return "Anime"
        case .people:  return "People"
        }
    }
}
