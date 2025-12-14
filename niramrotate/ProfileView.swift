//
//  ProfileView.swift
//  niramrotate
//
//  Created by aravinthan.selvaraj on 14/12/25.
//

import SwiftUI

struct ProfileView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("Account") {
                    Text("Apple ID: Signed In")
                }

                Section("Danger Zone") {
                    Button("Clear All Bundles", role: .destructive) {
                        // wipe storage
                    }

                    Button("Reset App", role: .destructive) {
                        // nuke everything
                    }
                }
            }
            .navigationTitle("Profile")
        }
    }
}
