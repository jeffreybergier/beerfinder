//
//  MapAnimator.swift
//  BeerFinder
//
//  Created by Jeffrey Bergier on 4/24/17.
//  Copyright © 2017 Jeffrey Bergier. All rights reserved.
//

import MapKit

internal protocol MapAnimatable: Resettable {
    var map: MKMapView? { get set }
    func perform(_: (() -> Void)?, whenMapFinishesAnimating: (() -> Void)?)
}

internal protocol HasMapAnimatable {
    var mapAnimator: MapAnimatable { get set }
}

internal extension HasMapAnimatable {
    internal mutating func configure(with mapAnimator: MapAnimatable?) {
        guard let mapAnimator = mapAnimator else { return }
        self.mapAnimator = mapAnimator
    }
}

internal class MapAnimator: NSObject, MapAnimatable, MKMapViewDelegate {
    
    private var mapFinishedAnimating: (() -> Void)?
    
    internal var map: MKMapView? {
        didSet {
            oldValue?.delegate = nil
            self.map?.delegate = self
            self.reset()
        }
    }
    
    internal func perform(_ action: (() -> Void)?, whenMapFinishesAnimating completion: (() -> Void)?) {
        self.mapFinishedAnimating = completion
        action?()
    }
    
    internal func reset() {
        self.mapFinishedAnimating = nil
    }
    
    @objc internal func mapView(_ map: MKMapView, regionDidChangeAnimated animated: Bool) {
        self.mapFinishedAnimating?()
        self.reset()
    }
    
}
