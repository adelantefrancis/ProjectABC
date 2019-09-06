//
//  DestinationLocationViewController.swift
//  ProjectABC
//
//  Created by Francis Adelante on 9/4/19.
//  Copyright © 2019 Developer. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import Alamofire

class DestinationLocationViewController: UIViewController {
    
    @IBOutlet var mapView: GMSMapView!
    var resultsViewController: GMSAutocompleteResultsViewController?
    var searchController: UISearchController?
    var resultView: UITextView?
    var userLocation: CLLocationCoordinate2D?
    var viewModel:  DestinationLocationViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = DestinationLocationViewModel()
        viewModel.destinationLocationViewModelDelegate = self
        
        resultsViewController = GMSAutocompleteResultsViewController()
        resultsViewController?.delegate = self
        
        searchController = UISearchController(searchResultsController: resultsViewController)
        searchController?.searchResultsUpdater = resultsViewController
        
        // Put the search bar in the navigation bar.
        searchController?.searchBar.sizeToFit()
        navigationItem.titleView = searchController?.searchBar
        
        // When UISearchController presents the results view, present it in
        // this view controller, not one further up the chain.
        definesPresentationContext = true
        
        // Prevent the navigation bar from being hidden when searching.
        searchController?.hidesNavigationBarDuringPresentation = false
         searchController?.searchBar.placeholder = "Destination"
    }
    
    
    func didSelectDestination(place: GMSPlace) {
        searchController?.searchBar.text = "\(place.name!)"
        
        let camera = GMSCameraPosition.camera(withLatitude: place.coordinate.latitude, longitude: place.coordinate.longitude, zoom: 6, bearing: 270, viewingAngle: 45)
        
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
        marker.map = mapView
        self.mapView.camera = camera
        
        CATransaction.begin()
        CATransaction.setValue(1.0, forKey: kCATransactionAnimationDuration)
        self.mapView.animate(toZoom: 12)
        CATransaction.commit()
        
        drawRoute(destination: CLLocationCoordinate2D(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude))
    }
    
    func drawRoute(destination: CLLocationCoordinate2D) {
        
        viewModel.getDotsToDrawRoute(positions: [userLocation!,destination]) { (path) in

            let polyline = GMSPolyline(path: path)
            polyline.strokeColor = .black
            polyline.strokeWidth = 3.0
            polyline.map = self.mapView
        }
    }
}

extension DestinationLocationViewController: DestinationLocationViewModelDelegate {
  
    func didFinishGettingUserLocation(with latitude: Double, longitude: Double) {
        let camera = GMSCameraPosition.camera(withLatitude: latitude, longitude: longitude, zoom: 6, bearing: 270, viewingAngle: 45)
        
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        marker.map = mapView
            self.mapView.camera = camera
        
        CATransaction.begin()
        CATransaction.setValue(2.0, forKey: kCATransactionAnimationDuration)
            self.mapView.animate(toZoom: 16)
        CATransaction.commit()
        viewModel.stopInitialLocation()
        userLocation = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
   
    
}
extension DestinationLocationViewController: GMSAutocompleteResultsViewControllerDelegate {
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                           didAutocompleteWith place: GMSPlace) {
        searchController?.isActive = false
        didSelectDestination(place: place)
        
    }
    
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                           didFailAutocompleteWithError error: Error){
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}
