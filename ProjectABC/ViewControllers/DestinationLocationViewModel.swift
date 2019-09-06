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
import Alamofire
import GoogleMaps

protocol DestinationLocationViewModelDelegate {
    func didFinishGettingUserLocation(with latitude: Double, longitude: Double)
}

class DestinationLocationViewModel: NSObject {
    
    var destinationLocationViewModelDelegate: DestinationLocationViewModelDelegate?
    var locationManager = CLLocationManager()
    var resultsViewController: GMSAutocompleteResultsViewController?
    var searchController: UISearchController!
    
    override init() {
        super.init()
        getUserLocation()

    }

    func stopInitialLocation(){
        locationManager.stopUpdatingLocation()
    }
    
    func getDotsToDrawRoute(positions : [CLLocationCoordinate2D], completion: @escaping(_ path : GMSPath) -> Void) {
        if positions.count > 1 {
            let origin = positions.first
            let destination = positions.last
            var wayPoints = ""
            for point in positions {
                wayPoints = wayPoints.count == 0 ? "\(point.latitude),\(point.longitude)" : "\(wayPoints)|\(point.latitude),\(point.longitude)"
            }
            let request = "https://maps.googleapis.com/maps/api/directions/json"
            let parameters : [String : String] = ["origin" : "\(origin!.latitude),\(origin!.longitude)", "destination" : "\(destination!.latitude),\(destination!.longitude)", "wayPoints" : wayPoints, "key" : Constant().googleAPIKey]
            
            AF.request(request, method:.get, parameters : parameters).responseJSON(completionHandler: { response in
                
                guard let dictionary = response.value as? [String : AnyObject]
                    else {
                        return
                }
                if let routes = dictionary["routes"] as? [[String : AnyObject]] {
                    if routes.count > 0 {
                        var first = routes.first
                        if let legs = first!["legs"] as? [[String : AnyObject]] {
                            let fullPath : GMSMutablePath = GMSMutablePath()
                            for leg in legs {
                                if let steps = leg["steps"] as? [[String : AnyObject]] {
                                    for step in steps {
                                        if let polyline = step["polyline"] as? [String : AnyObject] {
                                            if let points = polyline["points"] as? String {
                                                fullPath.appendPath(path: GMSMutablePath(fromEncodedPath: points))
                                            }
                                        }
                                    }
                                    completion(fullPath)
                                }
                            }
                        }
                    }
                }
            })
        }
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
