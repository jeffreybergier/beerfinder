//
//  PlaceProximityViewController.swift
//  BeerFinder
//
//  Created by Jeffrey Bergier on 4/26/17.
//  Copyright © 2017 Jeffrey Bergier. All rights reserved.
//

import UIKit

internal class PlaceProximityViewController: UIViewController, HasContinuousUserMovementMonitorable {
    
    internal class func newVC(movementMonitor: ContinuousUserMovementMonitorable? = nil) -> PlaceProximityViewController {
        let sb = UIStoryboard(name: "PlacePrxomity", bundle: Bundle(for: self))
        var vc = sb.instantiateInitialViewController() as! PlaceProximityViewController
        vc.configure(with: movementMonitor)
        return vc
    }
    
    internal var movementMonitor: ContinuousUserMovementMonitorable = ContinuousUserMovementMonitor()

    
}
