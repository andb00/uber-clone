//
//  HomeView.swift
//  uber-clone
//
//  Created by Andrew Betancourt on 5/25/24.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        ZStack(alignment: .top) {
            UberMapViewRepresentable()
                .ignoresSafeArea()
            
            LocationSearchActivationView()
                .padding(.top, 72)
            
            MapViewActionButton()
                .padding(.leading)
                .padding(.top, 4)
            
        }
    }
}

#Preview {
    HomeView()
}
