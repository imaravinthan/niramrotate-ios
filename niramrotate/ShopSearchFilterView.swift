//
//  ShopSearchFilterView.swift
//  niramrotate
//
//  Created by aravinthan.selvaraj on 16/12/25.
//

import SwiftUI

struct ShopFilterView: View {

    @Binding var filters: ShopFilters
    let onApply: () -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {

                // MARK: - Sorting
                Section("Sorting") {
                    Picker("Order", selection: $filters.sorting) {
                        ForEach(ShopFilters.Sorting.allCases, id: \.self) { sort in
                            Text(sortLabel(sort))
                                .tag(sort)
                        }
                    }
                }

                // MARK: - Categories
                Section("Categories") {
                    ForEach(ShopFilters.Category.allCases, id: \.self) { category in
                        Toggle(
                            categoryLabel(category),
                            isOn: bindingForCategory(category)
                        )
                    }
                }

                // MARK: - Purity
                Section("Purity") {
                    ForEach(ShopFilters.Purity.allCases, id: \.self) { purity in
                        Toggle(
                            purityLabel(purity),
                            isOn: bindingForPurity(purity)
                        )
                    }
                }

                // MARK: - Preferences
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

    private func bindingForCategory(
        _ category: ShopFilters.Category
    ) -> Binding<Bool> {
        Binding(
            get: { filters.categories.contains(category) },
            set: { enabled in
                if enabled {
                    filters.categories.insert(category)
                } else {
                    filters.categories.remove(category)
                }
            }
        )
    }

    private func bindingForPurity(
        _ purity: ShopFilters.Purity
    ) -> Binding<Bool> {
        Binding(
            get: { filters.purity.contains(purity) },
            set: { enabled in
                if enabled {
                    filters.purity.insert(purity)
                } else {
                    filters.purity.remove(purity)
                }
            }
        )
    }

    // MARK: - Labels

    private func categoryLabel(
        _ category: ShopFilters.Category
    ) -> String {
        switch category {
        case .general: return "General"
        case .anime:   return "Anime"
        case .people:  return "People"
        }
    }

    private func purityLabel(
        _ purity: ShopFilters.Purity
    ) -> String {
        switch purity {
        case .sfw:      return "SFW"
        case .sketchy:  return "Sketchy"
        case .nsfw:     return "NSFW"
        }
    }

    private func sortLabel(
        _ sort: ShopFilters.Sorting
    ) -> String {
        switch sort {
        case .latest:     return "Latest"
        case .hot:        return "Hot"
        case .toplist:    return "Toplist"
        case .relevance:  return "Relevance"
        case .random:     return "Random"
        }
    }
}
