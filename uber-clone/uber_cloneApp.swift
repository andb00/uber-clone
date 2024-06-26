//
//  uber_cloneApp.swift
//  uber-clone
//
//  Created by Andrew Betancourt on 5/24/24.
//

import SwiftUI

@main
struct uber_cloneApp: App {
    @StateObject var locationViewModel = LocationSearchViewModel()
    
    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(locationViewModel)
        }
    }
}
