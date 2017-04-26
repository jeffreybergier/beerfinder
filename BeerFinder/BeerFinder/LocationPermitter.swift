//
//  LocationPermitter.swift
//  BeerFinder
//
//  Created by Jeffrey Bergier on 4/17/17.
//  Copyright © 2017 Jeffrey Bergier. All rights reserved.
//

import CoreLocation

internal protocol LocationPermittable {
    var permission: CLAuthorizationStatus { get }
    func requestPermission(_ completionHandler: ((CLAuthorizationStatus) -> Void)?)
}

internal protocol HasLocationPermittable {
    var locationPermitter: LocationPermittable { get set }
}

internal extension HasLocationPermittable {
    internal mutating func configure(with permitter: LocationPermittable?) {
        guard let permitter = permitter else { return }
        self.locationPermitter = permitter
    }
}

internal class LocationPermitter: NSObject, CLLocationManagerDelegate, LocationPermittable {
    
    private var permissionHandler: ((CLAuthorizationStatus) -> Void)?
    private let manager = CLLocationManager()
    
    internal var permission: CLAuthorizationStatus {
        return CLLocationManager.authorizationStatus()
    }
    
    internal override init() {
        super.init()
        self.manager.desiredAccuracy = kCLLocationAccuracyBest
        self.manager.delegate = self
    }
    
    @objc internal func requestPermission(_ completionHandler: ((CLAuthorizationStatus) -> Void)?) {
        self.manager.requestWhenInUseAuthorization()
        self.permissionHandler = completionHandler
    }
    
    @objc internal func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        self.permissionHandler?(status)
        self.permissionHandler = nil
    }
}
