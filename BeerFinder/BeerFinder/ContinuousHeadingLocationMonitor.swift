//
//  ContinuousHeadingLocationMonitor.swift
//  BeerFinder
//
//  Created by Jeffrey Bergier on 4/26/17.
//  Copyright © 2017 Jeffrey Bergier. All rights reserved.
//

import CoreLocation

internal protocol ContinuousUserMovementMonitorable: Resettable {
    var allowedToDisplayHeadingCalibationUI: Bool { get set }
    var updated: ((Result<(CLLocation, CLLocationDirection)>) -> Void)? { get set }
    var latestLocation: CLLocation? { get }
    var latestHeading: CLLocationDirection? { get }
    func start(maxUpdateFrequency: TimeInterval)
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
    
    var allowedToDisplayHeadingCalibationUI = true
    var updated: ((Result<(CLLocation, CLLocationDirection)>) -> Void)?
    
    var latestLocation: CLLocation? {
        return self.manager.location
    }
    var latestHeading: CLLocationDirection? {
        return self.manager.heading?.trueHeading
    }
    private var latestError: Error?
    
    private var timer: Timer?
    
    internal init(allowedToDisplayHeadingCalibationUI: Bool) {
        self.allowedToDisplayHeadingCalibationUI = allowedToDisplayHeadingCalibationUI
        super.init()
        self.manager.desiredAccuracy = kCLLocationAccuracyBest
        self.manager.delegate = self
    }
    
    internal func start(maxUpdateFrequency interval: TimeInterval) {
        self.timer = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(self.timerFired(_:)), userInfo: nil, repeats: true)
        self.manager.startUpdatingHeading()
        self.manager.startUpdatingLocation()
    }
    
    internal func reset() {
        self.manager.stopUpdatingHeading()
        self.manager.stopUpdatingLocation()
        self.timer?.invalidate()
        self.timer = nil
        self.latestError = nil
        self.updated = nil
        self.nextLocation = nil
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
        guard let completion = self.updated else { return }
        
        let _location = self.latestLocation
        let _heading = self.latestHeading
        let _error = self.latestError
        
        if let error = _error {
            // clear the error here so its not permanent between updates
            self.latestError = nil
            completion(.error(error))
            return
        }
        
        if let location = _location, let heading = _heading {
            completion(.success(location, heading))
        }
    }
    
    @objc internal func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        // clear any errors that may have happened, clearly things are working now
        self.latestError = nil
        // if the next location function was called and we have a completion handler for that, do this
        guard let nextLocation = self.nextLocation else { return }
        // clear out the completion handler IVAR
        self.nextLocation = nil
        // call the closure
        nextLocation(.success(location))
    }
    
    @objc internal func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        // clear any errors that may have happened, clearly things are working now
        self.latestError = nil
    }
    
    @objc internal func locationManagerShouldDisplayHeadingCalibration(_ manager: CLLocationManager) -> Bool {
        return self.allowedToDisplayHeadingCalibationUI
    }
    
    @objc internal func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // store the error for the timer
        self.latestError = error
        // if the next location function was called and we have a completion handler for that, do this
        guard let nextLocation = self.nextLocation else { return }
        // clear out the completion handler IVAR
        self.nextLocation = nil
        // call the closure
        nextLocation(.error(error))
    }
    
}
