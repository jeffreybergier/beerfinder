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

private extension UIViewController {
    @IBAction private func goBack() {
        self.dismiss(animated: true, completion: nil)
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

extension CLLocationDirection {
    var radians: CGFloat {
        return CGFloat(self) * CGFloat.pi / 180.0
    }
}

extension MKCoordinateRegion {
    
    enum Zoom {
        case normal, close
        var degrees: CLLocationDegrees {
            switch self {
            case .normal:
                return 0.01
            case .close:
                return 0.0015
            }
        }
    }
    
    init(location: CLLocation, zoom: Zoom = .normal) {
        let coordinate = location.coordinate
        let span = MKCoordinateSpan(latitudeDelta: zoom.degrees, longitudeDelta: zoom.degrees)
        self.init(center: coordinate, span: span)
    }
    init(coordinate: CLLocationCoordinate2D, zoom: Zoom = .normal) {
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        self.init(location: location, zoom: zoom)
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
