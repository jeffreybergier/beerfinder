//
//  ContinuousHeadingLocationMonitor.swift
//  BeerFinder
//
//  Created by Jeffrey Bergier on 4/26/17.
//  Copyright © 2017 Jeffrey Bergier. All rights reserved.
//

import CoreLocation

internal protocol ContinuousUserMovementMonitorable {
    var updated: ((Result<(CLLocation, CLLocationDirection)>) -> Void)? { get set }
    var latestLocation: CLLocation? { get }
    var latestHeading: CLLocationDirection? { get }
    func start(maxUpdateFrequency: TimeInterval)
    func stop()
    func next(location: ((Result<CLLocation>) -> Void)?)
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
    
    var updated: ((Result<(CLLocation, CLLocationDirection)>) -> Void)? {
        didSet {
            if self.updated == nil {
                self.stop()
            }
        }
    }
    
    private(set) var latestLocation: CLLocation?
    private(set) var latestHeading: CLLocationDirection?
    private var latestError: Error?
    
    private var timer: Timer?
    
    internal override init() {
        super.init()
        self.manager.desiredAccuracy = kCLLocationAccuracyBest
        self.manager.delegate = self
    }
    
    internal func start(maxUpdateFrequency interval: TimeInterval) {
        guard self.updated != nil else { return }
        self.timer = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(self.timerFired(_:)), userInfo: nil, repeats: true)
        self.manager.startUpdatingHeading()
        self.manager.startUpdatingLocation()
    }
    
    internal func stop() {
        self.timer?.invalidate()
        self.timer = nil
        self.manager.startUpdatingHeading()
        self.manager.startUpdatingLocation()
    }
    
    private var nextLocation: ((Result<CLLocation>) -> Void)?
    
    internal func next(location completion: ((Result<CLLocation>) -> Void)?) {
        if let location = self.latestLocation {
            completion?(.success(location))
        } else if let error = self.latestError {
            completion?(.error(error))
        } else {
            self.nextLocation = completion
        }
    }
    
    @objc private func timerFired(_ timer: Timer?) {
        let _location = self.latestLocation
        let _heading = self.latestHeading
        let _error = self.latestError
        
        if let error = _error {
            self.latestError = nil
            self.updated?(.error(error))
            return
        }
        
        if let location = _location, let heading = _heading {
            self.updated?(.success(location, heading))
        }
    }
    
    @objc internal func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        self.latestError = nil
        self.latestLocation = location
        self.nextLocation?(.success(location))
        self.nextLocation = nil
    }
    
    @objc internal func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        self.latestError = nil
        self.latestHeading = newHeading.trueHeading
    }
    
    @objc internal func locationManagerShouldDisplayHeadingCalibration(_ manager: CLLocationManager) -> Bool {
        return true
    }
    
    @objc internal func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.latestError = error
        self.nextLocation?(.error(error))
        self.nextLocation = nil
    }
    
}
