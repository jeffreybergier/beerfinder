//
//  FindLocationViewController.swift
//  BeerFinder
//
//  Created by Jeffrey Bergier on 4/16/17.
//  Copyright © 2017 Jeffrey Bergier. All rights reserved.
//

import UIKit
import MapKit

internal class FindLocationViewController: UIViewController, HasLocatable, HasLocationPermittable, HasPlaceLocatable, HasMapAnimatable {

    @IBOutlet private weak var map: MKMapView?
    @IBOutlet private weak var buttonVC: LoaderAndButtonShowingViewController?
    
    internal var locationPermitter: LocationPermittable = LocationPermitter()
    internal var userLocator: UserLocatable = UserLocator()
    internal var placeLocator: PlaceLocatable = PlaceLocator()
    internal var mapAnimator: MapAnimatable = MapAnimator()
    
    internal class func newVC(locationPermitter: LocationPermittable? = nil,
                            userLocator: UserLocatable? = nil,
                            placeLocator: PlaceLocatable? = nil,
                            mapAnimator: MapAnimatable? = nil) -> FindLocationViewController
    {
        let storyboard = UIStoryboard(name: "FindLocation", bundle: Bundle(for: self))
        let vc = storyboard.instantiateInitialViewController() as! FindLocationViewController
        if let locationPermitter = locationPermitter {
            vc.locationPermitter = locationPermitter
        }
        if let userLocator = userLocator {
            vc.userLocator = userLocator
        }
        if let placeLocator = placeLocator {
            vc.placeLocator = placeLocator
        }
        if let mapAnimator = mapAnimator {
            vc.mapAnimator = mapAnimator
        }
        return vc
    }
    
    private var places: [PlaceLocator.MapItem]? {
        didSet {
            self.map?.removeAnnotations(oldValue ?? [])
            self.map?.addAnnotations(self.places ?? [])
        }
    }
    
    internal override func viewDidLoad() {
        super.viewDidLoad()
        self.buttonVC = self.childViewControllers.firstWithInferredType()
        self.updateButtonText()
        self.buttonVC?.buttonTapped = { [weak self] in
            self?.nextStep()
        }
    }
    
    internal override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.buttonVC?.updateUI(.button)
    }
    
    private func nextStep() {
        if let places = places, places.isEmpty == false {
            let placesVC = ListPlacesViewController.newVC()
            self.present(placesVC, animated: true, completion: nil)
        } else {
            switch self.locationPermitter.permission {
            case .notDetermined:
                self.step1_showRequestLocationPermission()
            case .authorizedAlways, .authorizedWhenInUse:
                self.step2_findUserLocation()
            case .denied:
                self.errorStep_showLocationDeniedAlert()
            case .restricted:
                self.errorStep_showLocationRestrictedAlert()
            }
        }
    }
    
    private func step1_showRequestLocationPermission() {
        self.buttonVC?.updateUI(.neither) {
            self.locationPermitter.requestPermission() { _ in
                self.nextStep()
            }
        }
    }
    
    private func step2_findUserLocation() {
        self.places = nil
        self.buttonVC?.updateUI(.neither) {
            self.userLocator.requestLocation() { result in
                self.buttonVC?.updateUI(.loader)
                switch result {
                case .success(let location):
                    self.step3_updateUI(with: location)
                case .error(let error):
                    self.errorStep_updateUI(with: error)
                }
            }
        }
    }
    
    private func step3_updateUI(with location: CLLocation) {
        let coordinate = location.coordinate
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        self.mapAnimator.setRegion(region, onMap: self.map) {
            self.step4_findPlaces(within: region)
        }
    }
    
    private func step4_findPlaces(within region: MKCoordinateRegion) {
        self.placeLocator.locateBeer(at: region) { result in
            switch result {
            case .success(let places):
                self.step5_updateUI(with: places)
            case .error(let error):
                self.errorStep_updateUI(with: error)
            }
        }
    }
    
    private func step5_updateUI(with places: [PlaceLocator.MapItem]) {
        guard places.isEmpty == false else {
            self.updateButtonText(with: "No Beer Found")
            self.buttonVC?.updateUI(.button)
            return
        }
        self.places = places
        self.updateButtonText(with: "Next")
        self.buttonVC?.updateUI(.button)
    }
    
    private func errorStep_updateUI(with error: Error) {
        self.updateButtonText(with: error.localizedDescription)
        self.buttonVC?.updateUI(.button)
    }
    
    private func errorStep_showLocationDeniedAlert() {
        self.buttonVC?.updateUI(.neither) {
            let vc = self.newDeniedAlert()
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    private func errorStep_showLocationRestrictedAlert() {
        self.buttonVC?.updateUI(.neither) {
            let vc = self.newRestrictedAlert()
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    private func updateButtonText(with message: String? = nil) {
        if let message = message {
            self.buttonVC?.setButton(text: message)
        } else {
            switch self.locationPermitter.permission {
            case .authorizedAlways, .authorizedWhenInUse, .notDetermined:
                self.buttonVC?.setButton(text: "Find Beer")
            case .denied, .restricted:
                self.buttonVC?.setButton(text: "Location Error")
            }
        }
    }
    
    private func newDeniedAlert() -> UIAlertController {
        let alertVC = UIAlertController(title: "Location Denied", message: "Location permissions has been denied. Please open settings to grant location permissions to this app.", preferredStyle: .alert)
        let settings = UIAlertAction(title: "Settings", style: .default) { action in
            self.updateButtonText()
            self.buttonVC?.updateUI(.button) {
                let appSettings = URL(string: UIApplicationOpenSettingsURLString)!
                UIApplication.shared.open(appSettings, options: [:], completionHandler: nil)
            }
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { action in
            self.updateButtonText()
            self.buttonVC?.updateUI(.button)
        }
        alertVC.addAction(settings)
        alertVC.addAction(cancel)
        return alertVC
    }
    
    private func newRestrictedAlert() -> UIAlertController {
        let alertVC = UIAlertController(title: "Location Restricted", message: "Contact your device administrator to continue using this app.", preferredStyle: .alert)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { action in
            self.updateButtonText()
            self.buttonVC?.updateUI(.button)
        }
        alertVC.addAction(cancel)
        return alertVC
    }
}
