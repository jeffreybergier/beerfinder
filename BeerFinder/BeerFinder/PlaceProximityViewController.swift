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
        
        self.hardModeVC = self.childViewControllers.first()
        
        guard let locations = self.locations else { fatalError("This view controller must have a SinglePlaceUserLocatable before being loaded") }
        
        let region = MKCoordinateRegion(location: locations.userLocation, zoom: .close)
        self.map?.setRegion(region, animated: false)
        
        let place = locations.place
        self.map?.addAnnotation(place)
        self.nameLabel?.text = place.name
        
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
