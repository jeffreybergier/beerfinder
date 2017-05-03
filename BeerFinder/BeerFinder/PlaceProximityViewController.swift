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
    
    internal var movementMonitor: ContinuousUserMovementMonitorable = ContinuousUserMovementMonitor(allowedToDisplayHeadingCalibationUI: true)
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
        
        self.hardModeVC = self.childViewControllers.first()
        
        guard let locations = self.locations else { fatalError("This view controller must have a SinglePlaceUserLocatable before being loaded") }
        
        let place = locations.place
        let userLocation = locations.userLocation
        
        // configure the map
        let region = MKCoordinateRegion(location: userLocation, zoom: .close)
        self.map?.addAnnotation(place)
        self.map?.setRegion(region, animated: false)
        
        // configure your textfields
        self.nameLabel?.text = place.title!
        let distance = userLocation.distance(from: place.coordinate)
        self.distanceLabel?.text = self.distanceFormatter.localizedDistance(from: distance)
        
        // begin
        self.beginGuidingUser(to: place)
    }
    
    private func beginGuidingUser(to place: Place) {
        self.movementMonitor.updated = { [weak self] result in
            guard case .success(let location, let heading) = result else { return }
            if let distanceLabel = self?.distanceLabel {
                let distance = location.distance(from: place.coordinate)
                distanceLabel.text = self?.distanceFormatter.localizedDistance(from: distance)
            }
            if let map = self?.map, let pointerView = self?.pointerView {
                // configure the camera
                let camera = map.camera.copy() as! MKMapCamera // map doesn't animate unless we give it a new object
                camera.heading = heading
                camera.centerCoordinate = location.coordinate
                
                // configure the finger
                let course = CGFloat(location.course(to: place.coordinate))
                let adjustedCourse = course.courseByAdjusting(for: heading.radians)
                
                // animate those things together
                UIView.animate(withDuration: kLocationUpdateInterval) {
                    map.camera = camera
                    pointerView.transform = CGAffineTransform(rotationAngle: adjustedCourse)
                }
            }
        }
        self.movementMonitor.start(maxUpdateFrequency: kLocationUpdateInterval)
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return self.hardModeVC?.preferredStatusBarStyle ?? .default
    }
}
