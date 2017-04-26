//
//  MapAnimator.swift
//  BeerFinder
//
//  Created by Jeffrey Bergier on 4/24/17.
//  Copyright © 2017 Jeffrey Bergier. All rights reserved.
//

import MapKit

internal protocol MapAnimatable {
    func setRegion(_: MKCoordinateRegion, onMap: MKMapView?, completion: (() -> Void)?)
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
    
    private var oldDelegate: MKMapViewDelegate?
    private var animationCompletion: (() -> Void)?
    
    internal func setRegion(_ region: MKCoordinateRegion, onMap map: MKMapView?, completion: (() -> Void)?) {
        guard let map = map else { completion?(); return; }
        self.animationCompletion = completion
        self.oldDelegate = map.delegate
        map.delegate = self
        map.setRegion(region, animated: true)
    }
    
    @objc internal func mapView(_ map: MKMapView, regionDidChangeAnimated animated: Bool) {
        map.delegate = self.oldDelegate
        animationCompletion?()
        self.animationCompletion = nil
    }
    
}
