//
//  CreateBundleView.swift
//  niramrotate
//
//  Created by aravinthan.selvaraj on 14/12/25.
//

import SwiftUI

struct CreateBundleView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Button("Create New Bundle") {
                    // open bundle creation flow
                }

                Button("Add Images to Bundle") {
                    // image picker
                }
            }
            .navigationTitle("Create")
        }
    }
}
