//
//  LocationSearchViewModel.swift
//  uber-clone
//
//  Created by Andrew Betancourt on 5/25/24.
//

import Foundation
import MapKit
import _MapKit_SwiftUI

@MainActor
class LocationSearchViewModel: NSObject, ObservableObject{
    
    // MARK - Properties
    
    @Published var results = [MKLocalSearchCompletion]()
    @Published var selectedUberLocation: UberLocation?
    @Published var pickupTime: String?
    @Published var dropOffTime: String?
    @Published var route: MKRoute?
    @Published var routeDestination: MKMapItem?
    @Published var cameraPosition: MapCameraPosition = .userLocation(fallback: .automatic)
    @Published var routeDisplaying: Bool = false
    
    private let searchCompleter = MKLocalSearchCompleter()
    var queryFragment: String = "" {
        didSet {
            searchCompleter.queryFragment = queryFragment
        }
    }
    
    var userLocation: CLLocationCoordinate2D?
    
    // MARK: Lifecycle
    
    override init() {
        super.init()
        searchCompleter.delegate = self
        searchCompleter.queryFragment = queryFragment
    }
    
    // MARK: - Helpers
    
    func selectLocation(_ localSearch: MKLocalSearchCompletion) async {
        let response =  await locationSearch(forLocalSearchCompletion: localSearch)

        guard let item = response?.mapItems.first else {return}
        let coordinate = item.placemark.coordinate
        selectedUberLocation = UberLocation(title: localSearch.title, coordinate: coordinate)
        print("DEBUG: Location coordinates \(coordinate)")
        print("DEBUG: selectedUberLocation \(String(describing: selectedUberLocation))")
    }
    
    func locationSearch(forLocalSearchCompletion localSearch: MKLocalSearchCompletion) async -> MKLocalSearch.Response? {
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = localSearch.title.appending(localSearch.subtitle)
        let results = try? await MKLocalSearch(request: searchRequest).start()
        
        return results
    }
    
    func computeRidePrice(forType type: RideType) -> Double {
        guard let destCoordinate = selectedUberLocation?.coordinate else { return 0.0}
        guard let userCoordinate = self.userLocation else { return 0.0}
        
        let userLocation = CLLocation(latitude: userCoordinate.latitude, longitude: userCoordinate.longitude)
        let destination = CLLocation(latitude: destCoordinate.latitude, longitude: destCoordinate.longitude)
        
        let tripDistanceInMeters = userLocation.distance(from: destination)
        return type.computePrice(for: tripDistanceInMeters)
    }
    
    func getDestinationRoute() async {
        guard let userLocation = await getUserLocation() else { print("userLocation is nil"); return }
        guard let destination = selectedUberLocation?.coordinate else {print("selectedUberLocation is nil"); return }
        
        let userPlacemark = MKPlacemark(coordinate: userLocation)
        let destPlacemark = MKPlacemark(coordinate: destination)
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: userPlacemark)
        request.destination = MKMapItem(placemark: destPlacemark)
        let directions = MKDirections(request: request)
        
        do {
            let response = try await directions.calculate()
            
            guard let route = response.routes.first else {return}
            self.route = route
            self.configurePickupAndDropoffTimes(with: route.expectedTravelTime)
        }catch {
            print(error.localizedDescription)
        }
        
            
    }
    
    func configurePickupAndDropoffTimes(with expectedTravelTime: Double) {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a"
        
        pickupTime = formatter.string(from: Date())
        dropOffTime = formatter.string(from: Date() + expectedTravelTime)
    }
    
    func getUserLocation() async -> CLLocationCoordinate2D? {
        let updates = CLLocationUpdate.liveUpdates()
        
        do {
            let update = try await updates.first { $0.location?.coordinate != nil }
            return update?.location?.coordinate
            
        }catch {
            print(error.localizedDescription)
            return nil
        }
    }
}

extension LocationSearchViewModel: @preconcurrency MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        self.results = completer.results
    }
}
