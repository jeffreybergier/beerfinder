//
//  ContinuousHeadingLocationMonitor.swift
//  BeerFinder
//
//  Created by Jeffrey Bergier on 4/26/17.
//  Copyright © 2017 Jeffrey Bergier. All rights reserved.
//

import CoreLocation

internal protocol ContinuousUserMovementMonitorable {
    func start()
    func stop()
    var headingUpdated: ((Result<CLLocationDirection>) -> Void)? { get set }
    var locationUpdated: ((Result<CLLocation>) -> Void)? { get set }
}

internal protocol HasContinuousUserMovementMonitorable {
    var movementMonitor: ContinuousUserMovementMonitorable { get set }
}

internal extension HasContinuousUserMovementMonitorable {
    internal mutating func configure(with movementMonitor: ContinuousUserMovementMonitorable?) {
        guard let movementMonitor = movementMonitor else { return }
        self.movementMonitor = movementMonitor
    }
}

class ContinuousUserMovementMonitor: NSObject, ContinuousUserMovementMonitorable, CLLocationManagerDelegate {
    
    private let manager = CLLocationManager()
    
    var headingUpdated: ((Result<CLLocationDirection>) -> Void)?
    var locationUpdated: ((Result<CLLocation>) -> Void)?
    
    internal override init() {
        super.init()
        self.manager.desiredAccuracy = kCLLocationAccuracyBest
        self.manager.delegate = self
    }
    
    internal func start() {
        self.manager.startUpdatingHeading()
        self.manager.startUpdatingLocation()
    }
    
    internal func stop() {
        self.manager.startUpdatingHeading()
        self.manager.startUpdatingLocation()
    }
    
    @objc internal func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        self.locationUpdated?(.success(location))
    }
    
    @objc internal func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        self.headingUpdated?(.success(newHeading.trueHeading))
    }
    
    @objc internal func locationManagerShouldDisplayHeadingCalibration(_ manager: CLLocationManager) -> Bool {
        return true
    }
    
    @objc internal func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.headingUpdated?(.error(error))
        self.locationUpdated?(.error(error))
    }
    
}
