//
//  MainTabView.swift
//  niramrotate
//
//  Created by aravinthan.selvaraj on 14/12/25.
//

import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            ShopView()
                .tabItem {
                    Label("Discover", systemImage: "sparkles")
                }
            CreateBundleView()
                .tabItem {
                    Label("Create", systemImage: "plus.circle")
                }
            LibraryView()
                .tabItem {
                    Label("Library", systemImage: "photo.on.rectangle")
                }
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle")
                }
        }
    }
}
