//
//  PlaceLocator.swift
//  BeerFinder
//
//  Created by Jeffrey Bergier on 4/17/17.
//  Copyright © 2017 Jeffrey Bergier. All rights reserved.
//

import MapKit

internal protocol PlaceLocatable {
    func locateBeer(at region: MKCoordinateRegion, completionHandler: ((Result<([PlaceLocator.MapItem], MKCoordinateRegion)>) -> Void)?)
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
    
    internal class MapItem: NSObject, MKAnnotation {
        let name: String
        let placemark: MKPlacemark
        init(name: String, placemark: MKPlacemark) {
            self.name = name
            self.placemark = placemark
            super.init()
        }
        let subtitle: String? = nil
        var coordinate: CLLocationCoordinate2D {
            return self.placemark.coordinate
        }
    }
    
    internal func locateBeer(at region: MKCoordinateRegion, completionHandler: ((Result<([PlaceLocator.MapItem], MKCoordinateRegion)>) -> Void)?) {
        let request = MKLocalSearchRequest()
        request.region = region
        request.naturalLanguageQuery = "bar"
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            if let response = response {
                let places = response.mapItems.flatMap { mapKitItem -> MapItem? in
                    guard let name = mapKitItem.name else { return nil }
                    return MapItem(name: name, placemark: mapKitItem.placemark)
                }
                completionHandler?(.success(places, response.boundingRegion))
            } else {
                completionHandler?(.error(error!))
            }
        }
    }
    
}
