//
//  PlaceProximityViewController.swift
//  BeerFinder
//
//  Created by Jeffrey Bergier on 4/26/17.
//  Copyright © 2017 Jeffrey Bergier. All rights reserved.
//

import MapKit
import UIKit

internal class PlaceProximityViewController: UIViewController, HasContinuousUserMovementMonitorable, HasSinglePlaceUserLocatable {
    
    @IBOutlet private weak var map: MKMapView?
    
    internal var movementMonitor: ContinuousUserMovementMonitorable = ContinuousUserMovementMonitor()
    internal var locations: SinglePlaceUserLocatable?
    
    internal class func newVC(movementMonitor: ContinuousUserMovementMonitorable? = nil,
                              locations: SinglePlaceUserLocatable? = nil) -> PlaceProximityViewController
    {
        let sb = UIStoryboard(name: "PlaceProximity", bundle: Bundle(for: self))
        var vc = sb.instantiateInitialViewController() as! PlaceProximityViewController
        vc.configure(with: movementMonitor)
        vc.configure(with: locations)
        return vc
    }
    
    internal override func viewDidLoad() {
        super.viewDidLoad()
        
        let userLocation = self.locations!.userLocation
        let region = MKCoordinateRegion(location: userLocation)
        self.map?.setRegion(region, animated: false)
        
        self.movementMonitor.headingUpdated = { [weak self] result in
            print("Heading: \(result)")
        }
        
        self.movementMonitor.locationUpdated = { [weak self] result in
            guard case .success(let location) = result else { return }
            let region = MKCoordinateRegion(location: location)
            self?.map?.setRegion(region, animated: true)
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

    
}
