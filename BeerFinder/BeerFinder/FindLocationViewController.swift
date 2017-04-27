//
//  FindLocationViewController.swift
//  BeerFinder
//
//  Created by Jeffrey Bergier on 4/16/17.
//  Copyright © 2017 Jeffrey Bergier. All rights reserved.
//

import UIKit
import MapKit

internal class FindLocationViewController: UIViewController, HasUserLocatable, HasLocationPermittable, HasPlaceLocatable, HasMapAnimatable, HasMultiPlaceUserLocatable {

    /*@IBOutlet*/ private weak var buttonVC: LoaderAndButtonShowingViewController?
    @IBOutlet private weak var map: MKMapView?
    
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
        var vc = storyboard.instantiateInitialViewController() as! FindLocationViewController
        vc.configure(with: locationPermitter)
        vc.configure(with: userLocator)
        vc.configure(with: placeLocator)
        vc.configure(with: mapAnimator)
        return vc
    }
    
    internal var locations: MultiPlaceUserLocatable? {
        didSet {
            self.map?.removeAnnotations(oldValue?.places ?? [])
            self.map?.removeAnnotations(self.map?.annotations ?? [])
            self.map?.addAnnotations(self.locations?.places ?? [])
        }
    }
    
    internal override func viewDidLoad() {
        super.viewDidLoad()
        self.buttonVC = self.childViewControllers.first()
        self.updateButtonText()
    }
    
    internal override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.buttonVC?.updateUI(.button)
    }
    
    private func nextStep() {
        if let locations = self.locations, locations.places.isEmpty == false {
            self.step6_showChooserVC(for: locations)
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
    
    private func updateMapToShowUser(_ show: Bool) {
        switch show {
        case true:
            self.map?.showsUserLocation = true
            self.map?.userTrackingMode = .follow
        case false:
            self.map?.showsUserLocation = false
            self.map?.userTrackingMode = .none
        }
    }
    
    private func step1_showRequestLocationPermission() {
        self.updateMapToShowUser(false)
        self.buttonVC?.updateUI(.neither) {
            self.buttonVC?.setLoader(text: "Finding Location…")
            self.locationPermitter.requestPermission() { _ in
                self.nextStep()
            }
        }
    }
    
    private func step2_findUserLocation() {
        self.updateMapToShowUser(false)
        self.locations = nil
        self.buttonVC?.updateUI(.neither) {
            self.buttonVC?.setLoader(text: "Finding Location…")
            self.buttonVC?.updateUI(.loader) {
                self.userLocator.requestLocation() { result in
                    switch result {
                    case .success(let location):
                        self.step3_updateUI(with: location)
                    case .error(let error):
                        self.errorStep_updateUI(with: error)
                    }
                }
            }
        }
    }
    
    private func step3_updateUI(with location: CLLocation) {
        let region = MKCoordinateRegion(location: location)
        self.mapAnimator.setRegion(region, onMap: self.map) {
            self.updateMapToShowUser(true)
            self.buttonVC?.updateUI(.neither) {
                self.step4_findPlaces(within: region, userLocation: location)
            }
        }
    }
    
    private func step4_findPlaces(within region: MKCoordinateRegion, userLocation: CLLocation) {
        self.buttonVC?.setLoader(text: "Finding Beer…")
        self.buttonVC?.updateUI(.loader) {
            self.placeLocator.locateBeer(at: region) { result in
                switch result {
                case .success(let places):
                    let locations = MultiPlaceUserLocation(userLocation: userLocation, places: places)
                    self.step5_updateUI(with: locations)
                case .error(let error):
                    self.errorStep_updateUI(with: error)
                }
            }
        }
    }
    
    private func step5_updateUI(with locations: MultiPlaceUserLocatable) {
        self.buttonVC?.updateUI(.neither) {
            guard locations.places.isEmpty == false else {
                self.updateButtonText(with: "No Beer Found")
                self.buttonVC?.updateUI(.button)
                return
            }
            self.locations = locations
            self.updateButtonText(with: "Next")
            self.buttonVC?.updateUI(.button)
        }
    }
    
    private func step6_showChooserVC(for locations: MultiPlaceUserLocatable) {
        precondition(locations.places.isEmpty == false, "Places to Choose from Must be Greater than 0")
        self.buttonVC?.updateUI(.neither) {
            var placesVC = ListPlacesViewController.newVC()
            placesVC.configure(with: locations)
            self.present(placesVC, animated: true, completion: nil)
        }
    }
    
    @IBAction private func reload() {
        self.locations = nil
        self.buttonVC?.updateUI(.neither) {
            self.updateButtonText()
            self.buttonVC?.updateUI(.button)
        }
    }
    
    @IBAction private func goForward() {
        self.nextStep()
    }
    
    private func errorStep_updateUI(with error: Error) {
        self.updateButtonText(with: error.localizedDescription)
        self.buttonVC?.updateUI(.button)
    }
    
    private func errorStep_showLocationDeniedAlert() {
        self.buttonVC?.updateUI(.neither) {
            let vc = UIAlertController.locationDenied(settingsHandler: { _ in
                self.updateButtonText()
                self.buttonVC?.updateUI(.button) {
                    UIApplication.shared.openSettings()
                }
            }, cancelHandler: { _ in
                self.updateButtonText()
                self.buttonVC?.updateUI(.button)
            })
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    private func errorStep_showLocationRestrictedAlert() {
        self.buttonVC?.updateUI(.neither) {
            let vc = UIAlertController.locationRestricted(cancelHandler: { _ in
                self.updateButtonText()
                self.buttonVC?.updateUI(.button)
            })
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
}
