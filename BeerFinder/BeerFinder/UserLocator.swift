//
//  Locator.swift
//  BeerFinder
//
//  Created by Jeffrey Bergier on 4/17/17.
//  Copyright © 2017 Jeffrey Bergier. All rights reserved.
//

import CoreLocation

protocol UserLocatable {
    func requestLocation(_: ((Result<CLLocation>) -> Void)?)
}

protocol UserLocatableConsumer {
    var userLocator: UserLocatable { get set }
}

extension UserLocatableConsumer {
    mutating func configure(with locater: UserLocatable) {
        self.userLocator = locater
    }
}

class UserLocator: NSObject, CLLocationManagerDelegate, UserLocatable {
    
    private var locateHandler: ((Result<CLLocation>) -> Void)?
    private let manager = CLLocationManager()
    
    override init() {
        super.init()
        self.manager.desiredAccuracy = kCLLocationAccuracyBest
        self.manager.delegate = self
    }
    
    func requestLocation(_ completionHandler: ((Result<CLLocation>) -> Void)?) {
        self.locateHandler = completionHandler
        self.manager.requestLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.locateHandler?(Result.success(locations.first!))
        self.locateHandler = nil
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.locateHandler?(Result.error(error))
        self.locateHandler = nil
    }
}
