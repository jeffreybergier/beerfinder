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
        
        var userLocation = self.locations!.userLocation
        let region = MKCoordinateRegion(location: userLocation, zoom: .close)
        self.map?.setRegion(region, animated: false)
        
        let place = self.locations!.place
        self.map?.addAnnotation(place)
        self.nameLabel?.text = place.name
    
        self.movementMonitor.headingUpdated = { [weak self] result in
            guard case .success(let userHeading) = result else { return }
            if let map = self?.map {
                let camera = map.camera.copy() as! MKMapCamera // map doesn't animate unless we give it a new object
                camera.heading = userHeading
                camera.centerCoordinate = userLocation.coordinate
                map.setCamera(camera, animated: true)
            }
            if let pointerView = self?.pointerView {
                let course = CGFloat(userLocation.course(to: place.coordinate))
                let adjustedCourse = course - userHeading.radians
                UIView.animate(withDuration: kLocationUpdateInterval) {
                    pointerView.transform = CGAffineTransform(rotationAngle: adjustedCourse)
                }
            }
        }
        
        self.movementMonitor.locationUpdated = { [weak self] result in
            guard case .success(let newLoc) = result else { return }
            userLocation = newLoc
            if let distanceLabel = self?.distanceLabel {
                let distance = userLocation.distance(from: place.coordinate)
                distanceLabel.text = self?.distanceFormatter.localizedDistance(from: distance)
            }
        }
    }
    
    internal override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.movementMonitor.start(maxUpdateFrequency: kLocationUpdateInterval)
    }
    
    internal override func viewDidDisappear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.movementMonitor.stop()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return self.hardModeVC?.preferredStatusBarStyle ?? .default
    }
}
