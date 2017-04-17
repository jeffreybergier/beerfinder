//
//  Locator.swift
//  BeerFinder
//
//  Created by Jeffrey Bergier on 4/17/17.
//  Copyright © 2017 Jeffrey Bergier. All rights reserved.
//

import CoreLocation

enum Result<T> {
    case success(T), error(Error)
}

class UserLocator: NSObject, CLLocationManagerDelegate {
    
    private var locateHandler: ((Result<CLLocation>) -> Void)?
    private var permissionHandler: ((CLAuthorizationStatus) -> Void)?
    private let manager = CLLocationManager()
    
    override init() {
        super.init()
        self.manager.desiredAccuracy = kCLLocationAccuracyBest
        self.manager.delegate = self
    }
    
    var permission: CLAuthorizationStatus {
        return CLLocationManager.authorizationStatus()
    }
    
    func requestLocation(_ completionHandler: ((Result<CLLocation>) -> Void)?) {
        self.locateHandler = completionHandler
        self.manager.requestLocation()
    }
    
    func requestPermission(_ completionHandler: ((CLAuthorizationStatus) -> Void)?) {
        self.manager.requestWhenInUseAuthorization()
        self.permissionHandler = completionHandler
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.locateHandler?(Result.success(locations.first!))
        self.locateHandler = nil
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.locateHandler?(Result.error(error))
        self.locateHandler = nil
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        self.permissionHandler?(status)
        self.permissionHandler = nil
    }
    
}
