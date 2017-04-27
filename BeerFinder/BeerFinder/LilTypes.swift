//
//  LilTypes.swift
//  BeerFinder
//
//  Created by Jeffrey Bergier on 4/17/17.
//  Copyright © 2017 Jeffrey Bergier. All rights reserved.
//

import MapKit
import CoreLocation
import UIKit

internal enum Result<T> {
    case success(T), error(Error)
}

internal extension Sequence {
    internal func first<T>(of type: T.Type? = nil) -> T? {
        return self.first(where: { $0 is T }) as? T
    }
}

internal extension UIButton {
    internal func disable() {
        self.isEnabled = false
        self.alpha = 0.4
    }
    internal func enable() {
        self.isEnabled = true
        self.alpha = 1.0
    }
}

internal extension CLLocation {
    internal func distance(from placeLocation: CLLocationCoordinate2D) -> CLLocationDistance {
        let placeCoordinate = CLLocation(latitude: placeLocation.latitude, longitude: placeLocation.longitude)
        let distance = self.distance(from: placeCoordinate)
        return distance
    }
}

extension MKCoordinateRegion {
    init(location: CLLocation) {
        let coordinate = location.coordinate
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        self.init(center: coordinate, span: span)
    }
    init(location: CLLocationCoordinate2D) {
        let coordinate = CLLocation(latitude: location.latitude, longitude: location.longitude)
        self.init(location: coordinate)
    }
}

internal extension UIApplication {
    @discardableResult
    internal func openSettings() -> URL {
        let appSettings = URL(string: UIApplicationOpenSettingsURLString)!
        self.open(appSettings, options: [:], completionHandler: nil)
        return appSettings
    }
}

internal extension UIAlertController {
    internal class func locationDenied(settingsHandler: ((UIAlertAction) -> Void)?, cancelHandler: ((UIAlertAction) -> Void)?) -> UIAlertController {
        let alertVC = UIAlertController(title: "Location Denied",
                                        message: "Location permissions has been denied. Please open settings to grant location permissions to this app.",
                                        preferredStyle: .alert)
        let settings = UIAlertAction(title: "Settings", style: .default, handler: settingsHandler)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: cancelHandler)
        alertVC.addAction(settings)
        alertVC.addAction(cancel)
        return alertVC
    }
    
    internal class func locationRestricted(cancelHandler: ((UIAlertAction) -> Void)?) -> UIAlertController {
        let alertVC = UIAlertController(title: "Location Restricted",
                                        message: "Contact your device administrator to continue using this app.",
                                        preferredStyle: .alert)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: cancelHandler)
        alertVC.addAction(cancel)
        return alertVC
    }
}
