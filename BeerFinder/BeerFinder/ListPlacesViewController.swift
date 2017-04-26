//
//  ListPlacesViewController.swift
//  BeerFinder
//
//  Created by Jeffrey Bergier on 4/17/17.
//  Copyright © 2017 Jeffrey Bergier. All rights reserved.
//

import UIKit
import MapKit

internal class ListPlacesViewController: UIViewController, HasMultiPlaceUserLocatable, HasDistanceCalculatable {
    
    @IBOutlet private weak var previousButton: UIButton?
    @IBOutlet private weak var nextButton: UIButton?
    @IBOutlet private weak var titleLabel: UILabel?
    @IBOutlet private weak var distanceLabel: UILabel?

    internal var locations: MultiPlaceUserLocatable?
    internal var selectionMade: ((SinglePlaceUserLocatable) -> Void)?
    internal var distanceCalculator: DistanceCalculatable = DistanceCalculator()
    
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
        guard let locations = self.locations, locations.places.isEmpty == false else { return }
        self.dismiss(animated: true) {
            let place = locations.places[self.currentIndex]
            let location = SinglePlaceUserLocation(userLocation: locations.userLocation, place: place)
            self.selectionMade?(location)
        }
    }
    
    private func updateUIWithData() {
        guard let locations = self.locations, locations.places.isEmpty == false else {
            self.titleLabel?.text = "No Beer Found"
            self.distanceLabel?.text = "0.0"
            self.currentIndex = 0
            return
        }
        
        let places = locations.places
        let place = places[self.currentIndex]
    
        self.titleLabel?.text = place.name
        
        let distance = locations.userLocation.distance(from: place.coordinate)
        self.distanceLabel?.text = self.distanceCalculator.localizedDistance(from: distance)
        
        if self.currentIndex >= places.count - 1 {
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
