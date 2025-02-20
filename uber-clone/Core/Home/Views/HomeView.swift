//
//  HomeView.swift
//  uber-clone
//
//  Created by Andrew Betancourt on 5/25/24.
//

import SwiftUI
import MapKit

struct HomeView: View {
    @State private var mapState = MapViewState.noInput
    @State private var selectedPlace: MKMapItem?
    @EnvironmentObject var locationViewModel: LocationSearchViewModel

    var body: some View {
        ZStack(alignment: .top) {
            
            Map(position: $locationViewModel.cameraPosition) {
                
                if let route = locationViewModel.route {
                    MapPolyline(route.polyline)
                        .stroke(Color.black, lineWidth: 3)
                    
                }
                
                // TODO: Add marker for destination route.
                
                UserAnnotation()
            }
            .tint(.orange)
                
            if mapState == .searchingForLocation{
                LocationSearchView(mapState: $mapState)
            }
            else if mapState == .noInput {
                LocationSearchActivationView()
                    .padding(.top, 72)
                    .onTapGesture {
                        withAnimation(.spring){
                            mapState = .searchingForLocation
                        }
                    }
            }
            
            MapViewActionButton(mapState: $mapState)
                .padding(.leading)
                .padding(.top, 4)
        }
        .edgesIgnoringSafeArea(.bottom)
        .onReceive(LocationManager.shared.$userLocation) { location in
            if let location = location {
                locationViewModel.userLocation = location
            }
        }
        
        if mapState == .locationSelected || mapState == .polylineAdded {
            RideRequestView().transition(.move(edge: .bottom))
        }
    }
}

#Preview {
    HomeView().environmentObject(LocationSearchViewModel())
}
