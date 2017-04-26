//
//  MultiplaceUserLocation.swift
//  BeerFinder
//
//  Created by Jeffrey Bergier on 4/25/17.
//  Copyright © 2017 Jeffrey Bergier. All rights reserved.
//

import CoreLocation

internal protocol MultiPlaceUserLocatable {
    var userLocation: CLLocation { get set }
    var places: [PlaceLocator.MapItem] { get set }
}

internal protocol HasMultiPlaceUserLocatable {
    var locations: MultiPlaceUserLocatable? { get set }
}

internal extension HasMultiPlaceUserLocatable {
    internal mutating func configure(with locations: MultiPlaceUserLocatable?) {
        guard let locations = locations else { return }
        self.locations = locations
    }
}

internal struct MultiPlaceUserLocation: MultiPlaceUserLocatable {
    internal var userLocation: CLLocation
    internal var places: [PlaceLocator.MapItem]
}

internal protocol SinglePlaceUserLocatable {
    var userLocation: CLLocation { get set }
    var place: PlaceLocator.MapItem { get set }
}

internal protocol HasSinglePlaceUserLocatable {
    var locations: SinglePlaceUserLocatable? { get set }
}

internal extension HasSinglePlaceUserLocatable {
    internal mutating func configure(with location: SinglePlaceUserLocatable?) {
        guard let location = location else { return }
        self.locations = location
    }
}

internal struct SinglePlaceUserLocation: SinglePlaceUserLocatable {
    internal var userLocation: CLLocation
    internal var place: PlaceLocator.MapItem
}
