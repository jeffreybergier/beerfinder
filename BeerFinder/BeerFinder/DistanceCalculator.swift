//
//  DistanceCalculator.swift
//  BeerFinder
//
//  Created by Jeffrey Bergier on 4/25/17.
//  Copyright © 2017 Jeffrey Bergier. All rights reserved.
//

import CoreLocation

internal protocol DistanceFormattable {
    func localizedDistance(from distance: CLLocationDistance) -> String
}

internal protocol HasDistanceFormattable {
    var distanceFormatter: DistanceFormattable { get set }
}

internal extension HasDistanceFormattable {
    internal mutating func configure(with distanceFormatter: DistanceFormattable?) {
        guard let distanceFormatter = distanceFormatter else { return }
        self.distanceFormatter = distanceFormatter
    }
}

internal class DistanceFormatter: DistanceFormattable {
    
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
