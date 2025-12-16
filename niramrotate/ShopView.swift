//
//  ShopView.swift
//  niramrotate
//
//  Created by aravinthan.selvaraj on 16/12/25.
//

import SwiftUI

struct ShopView: View {

    @StateObject private var vm = ShopViewModel()
    @State private var showFilters = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                if !vm.wallpapers.isEmpty {
                    ShopPostView(
                        wallpapers: vm.wallpapers,
                        onReachBottom: {
                            Task { await vm.loadNextPageIfNeeded() }
                        }
                    )
                } else {
                    ProgressView("Loading…")
                        .tint(.white)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showFilters.toggle()
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }
                }

                ToolbarItem(placement: .principal) {
                    TextField(
                        "Search wallpapers",
                        text: $vm.filters.query
                    )
                    .textFieldStyle(.roundedBorder)
                    .frame(maxWidth: 260)
                    .onSubmit {
                        Task { await vm.resetAndReload() }
                    }
                }
            }
        }
        .task {
            await vm.loadInitial()
        }
        .sheet(isPresented: $showFilters) {
            ShopFilterView(filters: $vm.filters) {
                Task { await vm.resetAndReload() }
            }
        }
    }
}
