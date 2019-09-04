//
//  DestinationLocationViewModel.swift
//  ProjectABC
//
//  Created by Francis Adelante on 9/4/19.
//  Copyright © 2019 Developer. All rights reserved.
//

import UIKit
import CoreLocation
import GooglePlaces

protocol DestinationLocationViewModelDelegate {
    func didFinishGettingUserLocation(with latitude: Double, longitude: Double)
    func presentDestinationLocationPicker(viewController: UIViewController)
    func calcelDestinationLocationPicker()
    func didSelectDestination(place: GMSPlace)
}

class DestinationLocationViewModel: NSObject {
    
    var destinationLocationViewModelDelegate: DestinationLocationViewModelDelegate?
    var locationManager = CLLocationManager()
    
    override init() {
        super.init()
        getUserLocation()
    }

    func didTappedDestination(){
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        
        // Specify the place data types to return.
        let fields: GMSPlaceField = GMSPlaceField(rawValue: UInt(GMSPlaceField.name.rawValue) |
            UInt(GMSPlaceField.placeID.rawValue))!
        autocompleteController.placeFields = fields
        
        // Specify a filter.
        let filter = GMSAutocompleteFilter()
        filter.type = .address
        autocompleteController.autocompleteFilter = filter
        
        // Display the autocomplete view controller.
        destinationLocationViewModelDelegate?.presentDestinationLocationPicker(viewController: autocompleteController)
    }
}

extension DestinationLocationViewModel: CLLocationManagerDelegate {
    private func getUserLocation() {
        if (CLLocationManager.locationServicesEnabled()){
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestAlwaysAuthorization()
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locationArray = locations as NSArray
        let locationObj = locationArray.lastObject as? CLLocation
        guard locationObj != nil else {
            return
        }
        
        let coordinates = locationObj!.coordinate
        destinationLocationViewModelDelegate?.didFinishGettingUserLocation(with: coordinates.latitude, longitude: coordinates.longitude)
    }
}

extension DestinationLocationViewModel: GMSAutocompleteViewControllerDelegate {
    
    // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        destinationLocationViewModelDelegate?.didSelectDestination(place: place)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    // User canceled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        destinationLocationViewModelDelegate?.calcelDestinationLocationPicker()
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
}
