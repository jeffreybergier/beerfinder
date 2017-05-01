//
//  PlaceLocator.swift
//  BeerFinder
//
//  Created by Jeffrey Bergier on 4/17/17.
//  Copyright © 2017 Jeffrey Bergier. All rights reserved.
//

import MapKit

internal protocol PlaceLocatable: Resettable {
    func locatePlaces(matchingQuery: String, within: MKCoordinateRegion, completion: ((Result<([Place], MKCoordinateRegion)>) -> Void)?)
}

internal protocol HasPlaceLocatable {
    var placeLocator: PlaceLocatable { get set }
}

internal extension HasPlaceLocatable {
    internal mutating func configure(with locatable: PlaceLocatable?) {
        guard let locatable = locatable else { return }
        self.placeLocator = locatable
    }
}

internal class PlaceLocator: PlaceLocatable {
    
    private var searchInProgress: MKLocalSearch?
    
    internal func reset() {
        self.searchInProgress?.cancel()
        self.searchInProgress = nil
    }
    
    func locatePlaces(matchingQuery query: String,
                      within region: MKCoordinateRegion,
                      completion: ((Result<([Place], MKCoordinateRegion)>) -> Void)?)
    {
        self.reset()
        let request = MKLocalSearchRequest()
        request.region = region
        request.naturalLanguageQuery = query
        let search = MKLocalSearch(request: request)
        self.searchInProgress = search
        search.start { response, error in
            if let response = response {
                let places = response.mapItems
                completion?(.success(places, response.boundingRegion))
            } else {
                completion?(.error(error!))
            }
        }
    }
}
