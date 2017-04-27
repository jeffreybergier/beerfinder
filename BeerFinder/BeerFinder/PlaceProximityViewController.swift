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
    
    @IBOutlet private weak var distanceLabel: UILabel?
    @IBOutlet private weak var nameLabel: UILabel?
    @IBOutlet private weak var map: MKMapView? {
        didSet {
            self.map?.userTrackingMode = .followWithHeading
        }
    }
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
        let region = MKCoordinateRegion(location: userLocation)
        self.map?.setRegion(region, animated: false)
        
        let place = self.locations!.place
        self.map?.addAnnotation(place)
        self.nameLabel?.text = place.name
    
        self.movementMonitor.headingUpdated = { [weak self] result in
            guard case .success(let heading) = result else { return }
            print(heading.trueHeading)
        }
        
        self.movementMonitor.locationUpdated = { [weak self] result in
            guard case .success(let userLocation) = result else { return }
            let distance = userLocation.distance(from: place.coordinate)
            self?.distanceLabel?.text = self?.distanceFormatter.localizedDistance(from: distance)
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
        if self.hardModeVC?.isHardMode == true {
            return .lightContent
        } else {
            return .default
        }
    }
}
