//
//  Locator.swift
//  BeerFinder
//
//  Created by Jeffrey Bergier on 4/17/17.
//  Copyright © 2017 Jeffrey Bergier. All rights reserved.
//

import CoreLocation

internal protocol UserLocatable {
    func requestLocation(_: ((Result<CLLocation>) -> Void)?)
}

internal protocol HasUserLocatable {
    var userLocator: UserLocatable { get set }
}

internal extension HasUserLocatable {
    internal mutating func configure(with locater: UserLocatable?) {
        guard let locater = locater else { return }
        self.userLocator = locater
    }
}

internal class UserLocator: NSObject, CLLocationManagerDelegate, UserLocatable {
    
    private var locateHandler: ((Result<CLLocation>) -> Void)?
    private let manager = CLLocationManager()
    
    internal override init() {
        super.init()
        self.manager.desiredAccuracy = kCLLocationAccuracyBest
        self.manager.delegate = self
    }
    
    internal func requestLocation(_ completionHandler: ((Result<CLLocation>) -> Void)?) {
        self.locateHandler = completionHandler
        self.manager.requestLocation()
    }
    
    @objc internal func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.locateHandler?(Result.success(locations.first!))
        self.locateHandler = nil
    }

    @objc internal func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.locateHandler?(Result.error(error))
        self.locateHandler = nil
    }
}
