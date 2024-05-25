//
//  HomeView.swift
//  uber-clone
//
//  Created by Andrew Betancourt on 5/25/24.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        UberMapViewRepresentable()
            .ignoresSafeArea()
    }
}

#Preview {
    HomeView()
}
