//
//  ShopView.swift
//  niramrotate
//
//  Created by aravinthan.selvaraj on 16/12/25.
//

import SwiftUI

struct ShopView: View {

    @StateObject private var vm = ShopViewModel()

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(vm.wallpapers) { wallpaper in
                    ShopPostView(wallpaper: wallpaper)
                        .frame(height: UIScreen.main.bounds.height)
                }

                if vm.isLoading {
                    ProgressView()
                        .padding()
                }
            }
        }
        .ignoresSafeArea()
        .task {
            await vm.loadNextPage()
        }
    }
}
