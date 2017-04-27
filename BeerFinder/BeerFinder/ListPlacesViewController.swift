//
//  ListPlacesViewController.swift
//  BeerFinder
//
//  Created by Jeffrey Bergier on 4/17/17.
//  Copyright © 2017 Jeffrey Bergier. All rights reserved.
//

import MapKit
import UIKit

internal class ListPlacesViewController: UIViewController, HasMultiPlaceUserLocatable, HasDistanceFormattable {
    
    @IBOutlet private weak var map: MKMapView?
    @IBOutlet private weak var previousButton: UIButton?
    @IBOutlet private weak var nextButton: UIButton?
    @IBOutlet private weak var titleLabel: UILabel?
    @IBOutlet private weak var distanceLabel: UILabel?

    internal var locations: MultiPlaceUserLocatable?
    internal var distanceFormatter: DistanceFormattable = DistanceFormatter()
    
    private var currentIndex = 0
    
    internal class func newVC(locations: MultiPlaceUserLocatable? = nil,
                              distanceFormatter: DistanceFormattable? = nil) -> ListPlacesViewController
    {
        let storyboard = UIStoryboard(name: "ListPlaces", bundle: Bundle(for: self))
        var vc = storyboard.instantiateInitialViewController() as! ListPlacesViewController
        vc.configure(with: locations)
        vc.configure(with: distanceFormatter)
        return vc
    }
    
    internal override func viewDidLoad() {
        super.viewDidLoad()
        
        let places = self.locations!.places
        self.map?.addAnnotations(places)
        
        let firstPlace = places.first!
        let region = MKCoordinateRegion(coordinate: firstPlace.coordinate, zoom: .close)
        self.map?.setRegion(region, animated: false)
        
        self.updateUIWithData()
    }
    
    @IBAction private func placeChosen(_ sender: NSObject?) {
        guard let locations = self.locations, locations.places.isEmpty == false else { return }
        let place = locations.places[self.currentIndex]
        let location = SinglePlaceUserLocation(userLocation: locations.userLocation, place: place)
        var vc = PlaceProximityViewController.newVC()
        vc.configure(with: location)
        self.present(vc, animated: true, completion: nil)
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
        
        let region = MKCoordinateRegion(coordinate: place.coordinate, zoom: .close)
        self.map?.setRegion(region, animated: true)
        
        let distance = locations.userLocation.distance(from: place.coordinate)
        self.distanceLabel?.text = self.distanceFormatter.localizedDistance(from: distance)
        
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
