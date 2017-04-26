//
//  DistanceCalculator.swift
//  BeerFinder
//
//  Created by Jeffrey Bergier on 4/25/17.
//  Copyright © 2017 Jeffrey Bergier. All rights reserved.
//

import CoreLocation

internal protocol DistanceCalculatable {
    func localizedDistance(from distance: CLLocationDistance) -> String
}

internal protocol HasDistanceCalculatable {
    var distanceCalculator: DistanceCalculatable { get set }
}

internal extension HasDistanceCalculatable {
    internal mutating func configure(with distanceCalculator: DistanceCalculatable?) {
        guard let distanceCalculator = distanceCalculator else { return }
        self.distanceCalculator = distanceCalculator
    }
}

internal class DistanceCalculator: DistanceCalculatable {
    
    private let formatter: LengthFormatter = {
        let f = LengthFormatter()
        f.unitStyle = .long
        f.numberFormatter.maximumFractionDigits = 1
        return f
    }()
    
    internal func localizedDistance(from distance: CLLocationDistance) -> String {
        let string = self.formatter.string(fromMeters: distance)
        return string
    }
    
}
