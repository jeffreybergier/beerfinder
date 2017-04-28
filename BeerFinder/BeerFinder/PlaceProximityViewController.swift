//
//  PlaceProximityViewController.swift
//  BeerFinder
//
//  Created by Jeffrey Bergier on 4/26/17.
//  Copyright © 2017 Jeffrey Bergier. All rights reserved.
//

import MapKit
import UIKit

internal class PlaceProximityViewController: UIViewController, HasContinuousUserMovementMonitorable, HasSinglePlaceUserLocatable, HasDistanceFormattable {
    
    @IBOutlet private weak var pointerView: UIView?
    @IBOutlet private weak var distanceLabel: UILabel?
    @IBOutlet private weak var nameLabel: UILabel?
    @IBOutlet private weak var map: MKMapView?
    
    /*@IBOutlet*/ private weak var hardModeVC: HardModeViewController?
    
    internal var movementMonitor: ContinuousUserMovementMonitorable = ContinuousUserMovementMonitor()
    internal var locations: SinglePlaceUserLocatable?
    internal var distanceFormatter: DistanceFormattable = DistanceFormatter()
    
    internal class func newVC(movementMonitor: ContinuousUserMovementMonitorable? = nil,
                              locations: SinglePlaceUserLocatable? = nil,
                              distanceFormatter: DistanceFormattable? = nil) -> PlaceProximityViewController
    {
        let sb = UIStoryboard(name: "PlaceProximity", bundle: Bundle(for: self))
        var vc = sb.instantiateInitialViewController() as! PlaceProximityViewController
        vc.configure(with: movementMonitor)
        vc.configure(with: locations)
        vc.configure(with: distanceFormatter)
        return vc
    }
    
    internal override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hardModeVC = self.childViewControllers.first()!
        
        let userLocation = self.locations!.userLocation
        let region = MKCoordinateRegion(location: userLocation, zoom: .close)
        self.map?.setRegion(region, animated: false)
        
        let place = self.locations!.place
        self.map?.addAnnotation(place)
        self.nameLabel?.text = place.name
    
        self.movementMonitor.headingUpdated = { [weak self] result in
            guard case .success(let direction) = result else { return }
//            if let pointerView = self?.pointerView {
//                pointerView.transform = CGAffineTransform(rotationAngle: direction.radians)
//            }
//            if let map = self?.map {
//                let camera = map.camera
//                camera.heading = direction
//                map.setCamera(camera, animated: true)
//            }
        }
        
        self.movementMonitor.locationUpdated = { [weak self] result in
            guard case .success(let userLocation) = result else { return }
            if let pointerView = self?.pointerView {
                let lat1 = userLocation.coordinate.latitude.radians
                let lon1 = userLocation.coordinate.longitude.radians
                
                let lat2 = place.coordinate.latitude.radians
                let lon2 = place.coordinate.longitude.radians
                
                let dLon = lon2 - lon1
                
                let y = sin(dLon) * cos(lat2)
                let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
                
                var radiansBearing = atan2(y, x)
                
                if radiansBearing < 0.0 {
                    radiansBearing += 2 * CGFloat.pi
                }
                print(radiansBearing)
                pointerView.transform = CGAffineTransform(rotationAngle: radiansBearing)
            }
            if let distanceLabel = self?.distanceLabel {
                let distance = userLocation.distance(from: place.coordinate)
                distanceLabel.text = self?.distanceFormatter.localizedDistance(from: distance)
            }
            if let map = self?.map {
                let camera = map.camera
                camera.centerCoordinate = userLocation.coordinate
                map.setCamera(camera, animated: true)
            }
        }
    }
    
    internal override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.movementMonitor.start()
    }
    
    internal override func viewDidDisappear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.movementMonitor.stop()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return self.hardModeVC?.preferredStatusBarStyle ?? .default
    }
}
