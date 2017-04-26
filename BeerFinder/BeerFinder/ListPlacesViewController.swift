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
    internal var placeSelection: ((PlaceLocator.MapItem) -> Void)?
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
    
    @IBAction private func placeChosen(_ sender: NSObject?) {
        self.dismiss(animated: true) {
            let place = self.places[self.currentIndex]
            self.placeSelection?(place)
        }
    }
    
    
    private func updateUIWithData() {
        let place = self.places[self.currentIndex]
        
        self.titleLabel?.text = place.name
        self.distanceLabel?.text = "\(place.placemark.coordinate.latitude)"
        
        if self.currentIndex >= self.places.count - 1 {
            self.nextButton?.disable()
        } else {
            self.nextButton?.enable()
        }
        if self.currentIndex <= 0 {
            self.previousButton?.disable()
        } else {
            self.previousButton?.enable()
        }
    }
    
    @IBAction private func next(_ sender: NSObject?) {
        self.currentIndex += 1
        self.updateUIWithData()
    }
    
    @IBAction private func previous(_ sender: NSObject?) {
        self.currentIndex -= 1
        self.updateUIWithData()
    }
    
}
