//
//  PlaceLocator.swift
//  BeerFinder
//
//  Created by Jeffrey Bergier on 4/17/17.
//  Copyright © 2017 Jeffrey Bergier. All rights reserved.
//

import MapKit

class PlaceLocator {
    
    func locateBeer(at region: MKCoordinateRegion, completionHandler: ((Any) -> Void)?) {
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = "beer"
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            //
        }
    }
    
}
