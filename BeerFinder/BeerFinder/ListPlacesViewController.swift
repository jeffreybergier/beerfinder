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
    
    @IBOutlet private weak var previousButton: UIButton?
    @IBOutlet private weak var nextButton: UIButton?
    @IBOutlet private weak var titleLabel: UILabel?
    @IBOutlet private weak var distanceLabel: UILabel?

    internal var places: [PlaceLocator.MapItem] = []
    private var currentIndex = 0
    
    internal class func newVC() -> ListPlacesViewController {
        let storyboard = UIStoryboard(name: "ListPlaces", bundle: Bundle(for: self))
        let vc = storyboard.instantiateInitialViewController() as! ListPlacesViewController
        return vc
    }
    
    internal override func viewDidLoad() {
        super.viewDidLoad()
        self.updateUIWithData()
    }
    
    private func updateUIWithData() {
        
    }
    
    @IBAction private func next(_ sender: NSObject?) {
        self.currentIndex += 1
    }
    
    @IBAction private func previous(_ sender: NSObject?) {
        self.currentIndex -= 1
    }
    
}
