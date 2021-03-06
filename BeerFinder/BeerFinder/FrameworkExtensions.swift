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

@objc internal protocol Place: MKAnnotation {
    var placemark: MKPlacemark { get }
}

extension MKMapItem: Place {
    public var title: String? {
        return self.name
    }
    public var subtitle: String? {
        return self.phoneNumber
    }
    public var coordinate: CLLocationCoordinate2D {
        return self.placemark.coordinate
    }
}

internal protocol Resettable {
    func reset()
}

internal enum Result<T> {
    case success(T), error(Error)
}

internal let kLocationUpdateInterval: TimeInterval = 0.5

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
    internal func course(to toLoc: CLLocationCoordinate2D) -> CLLocationDirection {
        let lat1 = self.coordinate.latitude.radians
        let lon1 = self.coordinate.longitude.radians
        
        let lat2 = toLoc.latitude.radians
        let lon2 = toLoc.longitude.radians
        
        let dLon = lon2 - lon1
        
        let y = sin(dLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
        
        var course = atan2(y, x)
        
        if course < 0.0 {
            course += 2 * CGFloat.pi
        }
        
        return CLLocationDirection(course)
    }
}

internal extension Double {
    internal var radians: CGFloat {
        let radians = CGFloat(self * Double.pi / 180.0)
        return radians
    }
}

internal extension CGFloat {
    internal func courseByAdjusting(for heading: CGFloat) -> CGFloat {
        var copy = self
        copy.adjust(for: heading)
        return copy
    }
    internal mutating func adjust(for heading: CGFloat) {
        self = self - heading
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
