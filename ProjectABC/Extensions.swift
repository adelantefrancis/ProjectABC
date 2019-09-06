//
//  Extensions.swift
//  ProjectABC
//
//  Created by Francis Adelante on 9/6/19.
//  Copyright © 2019 Developer. All rights reserved.
//

import GoogleMaps


extension GMSMutablePath {
    
    func appendPath(path : GMSPath?) {
        if let path = path {
            for i in 0..<path.count() {
                self.add(path.coordinate(at: i))
            }
        }
    }
}
