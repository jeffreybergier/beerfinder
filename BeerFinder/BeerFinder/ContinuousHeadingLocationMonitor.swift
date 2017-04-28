//
//  ContinuousHeadingLocationMonitor.swift
//  BeerFinder
//
//  Created by Jeffrey Bergier on 4/26/17.
//  Copyright © 2017 Jeffrey Bergier. All rights reserved.
//

import CoreLocation

internal protocol ContinuousUserMovementMonitorable {
    func start(maxUpdateFrequency: TimeInterval)
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
    
    private var latestLocation: CLLocation?
    private var latestHeading: CLLocationDirection?
    private var latestError: Error?
    
    private var timer: Timer?
    
    internal override init() {
        super.init()
        self.manager.desiredAccuracy = kCLLocationAccuracyBest
        self.manager.delegate = self
    }
    
    internal func start(maxUpdateFrequency interval: TimeInterval) {
        self.timer = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(self.timerFired(_:)), userInfo: nil, repeats: true)
        if self.locationUpdated != nil {
            self.manager.startUpdatingHeading()
        }
        if self.headingUpdated != nil {
            self.manager.startUpdatingLocation()
        }
    }
    
    internal func stop() {
        self.timer?.invalidate()
        self.timer = nil
        self.manager.startUpdatingHeading()
        self.manager.startUpdatingLocation()
    }
    
    @objc private func timerFired(_ timer: Timer?) {
        let _location = self.latestLocation
        let _heading = self.latestHeading
        let _error = self.latestError
        
        self.latestLocation = nil
        self.latestHeading = nil
        self.latestError = nil
        
        if let error = _error {
            self.locationUpdated?(.error(error))
            self.headingUpdated?(.error(error))
            return
        }
        
        if let location = _location {
            self.locationUpdated?(.success(location))
        }
        
        if let heading = _heading {
            self.headingUpdated?(.success(heading))
        }
    }
    
    @objc internal func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        self.latestLocation = location
    }
    
    @objc internal func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        self.latestHeading = newHeading.trueHeading
    }
    
    @objc internal func locationManagerShouldDisplayHeadingCalibration(_ manager: CLLocationManager) -> Bool {
        return true
    }
    
    @objc internal func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.latestError = error
    }
    
}
