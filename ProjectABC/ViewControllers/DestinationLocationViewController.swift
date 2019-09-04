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
class DestinationLocationViewController: UIViewController {
    
    @IBOutlet var mapView: GMSMapView!
    @IBOutlet var destinationTextfield: UITextField!
    
    var viewModel:  DestinationLocationViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = DestinationLocationViewModel()
        viewModel.destinationLocationViewModelDelegate = self
    }
    
    @IBAction func tappedDestination(_ sender: UIButton) {
        viewModel.didTappedDestination()
        
    }
    
}

extension DestinationLocationViewController: DestinationLocationViewModelDelegate {
  
    
    func calcelDestinationLocationPicker() {
        dismiss(animated: true, completion: nil)
    }
    
    func didSelectDestination(place: GMSPlace) {
      
        destinationTextfield.text = "\(String(describing: place.name)) \(String(describing: place.placeID)) \(String(describing: place.attributions))"
        dismiss(animated: true, completion: nil)
    }
    
    func presentDestinationLocationPicker(viewController: UIViewController) {
        present(viewController, animated: true, completion: nil)
    }
    
    
    func didFinishGettingUserLocation(with latitude: Double, longitude: Double) {
        let camera = GMSCameraPosition.camera(withLatitude: latitude, longitude: longitude, zoom: 6, bearing: 270, viewingAngle: 45)
        
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        marker.map = mapView
            self.mapView.camera = camera
        
        CATransaction.begin()
        CATransaction.setValue(2.0, forKey: kCATransactionAnimationDuration)
            self.mapView.animate(toZoom: 12)
        CATransaction.commit()
    }
    
    func didSelectDestination() {
        
    }
    
}
