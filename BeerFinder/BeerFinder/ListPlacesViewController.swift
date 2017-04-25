//
//  ListPlacesViewController.swift
//  BeerFinder
//
//  Created by Jeffrey Bergier on 4/17/17.
//  Copyright © 2017 Jeffrey Bergier. All rights reserved.
//

import UIKit
import MapKit

internal class ListPlacesViewController: UIViewController {
    
    @IBOutlet private weak var map: MKMapView?
    internal var places: [Any]?
    
    internal class func newVC() -> ListPlacesViewController {
        let storyboard = UIStoryboard(name: "ListPlaces", bundle: Bundle(for: self))
        let vc = storyboard.instantiateInitialViewController() as! ListPlacesViewController
        return vc
    }
    
}
