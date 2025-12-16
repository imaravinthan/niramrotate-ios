//
//  ShopSearchBarView.swift
//  niramrotate
//
//  Created by aravinthan.selvaraj on 16/12/25.
//

import SwiftUI

struct ShopSearchBarView: View {

    @Binding var query: String
    let onSubmit: () -> Void
    let onClear: () -> Void
    let onFilterTap: () -> Void

    @FocusState private var isFocused: Bool

    var body: some View {
        HStack(spacing: 10) {

            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)

                TextField("Search wallpapers", text: $query)
                    .focused($isFocused)
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                    .submitLabel(.search)
                    .onSubmit {
                        onSubmit()
                    }

                if !query.isEmpty {
                    Button {
                        query = ""
                        onClear()
                        isFocused = false
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(10)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 14))

            Button(action: onFilterTap) {
                Image(systemName: "slider.horizontal.3")
                    .font(.title3)
                    .padding(10)
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }
}
