//
//  FindLocationViewController.swift
//  BeerFinder
//
//  Created by Jeffrey Bergier on 4/16/17.
//  Copyright © 2017 Jeffrey Bergier. All rights reserved.
//

import UIKit
import MapKit

class FindLocationViewController: UIViewController, UserLocatableConsumer, LocationPermittableConsumer, PlaceLocatableConsumer {

    @IBOutlet private weak var buttonView: UIView?
    @IBOutlet private weak var labelView: UIView?
    @IBOutlet private weak var button: UIButton?
    @IBOutlet private weak var map: MKMapView?
    
    private var buttonViewConstraint: NSLayoutConstraint?
    private var labelViewConstraint: NSLayoutConstraint?
    
    private let viewShowConstant: CGFloat = -87
    private let viewHideConstant: CGFloat = 20
    
    var locationPermitter: LocationPermittable = LocationPermitter()
    var userLocator: UserLocatable = UserLocator()
    var placeLocator: PlaceLocatable = PlaceLocator()
    
    private var places: [PlaceLocator.MapItem]? {
        didSet {
            self.map?.removeAnnotations(oldValue ?? [])
            self.map?.addAnnotations(self.places ?? [])
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.buttonViewConstraint = self.buttonView?.topAnchor.constraint(equalTo: self.view.bottomAnchor, constant: self.viewShowConstant)
        self.labelViewConstraint = self.labelView?.topAnchor.constraint(equalTo: self.view.bottomAnchor, constant: self.viewHideConstant)
        self.buttonViewConstraint?.isActive = true
        self.labelViewConstraint?.isActive = true
        self.updateButtonText()
    }
    
    private func updateButtonText(with message: String? = nil) {
        if let message = message {
            self.button?.setTitle(message, for: .normal)
        } else {
            switch self.locationPermitter.permission {
            case .authorizedAlways, .authorizedWhenInUse, .notDetermined:
                self.button?.setTitle("Find Beer", for: .normal)
            case .denied, .restricted:
                self.button?.setTitle("Location Error", for: .normal)
            }
        }
    }
    
    @IBAction private func findLocationTapped(_ sender: NSObject?) {
        if let places = places, places.isEmpty == false {
            print("ready to go to new screen")
        } else {
            switch self.locationPermitter.permission {
            case .notDetermined:
                self.showRequestPermission()
            case .authorizedAlways, .authorizedWhenInUse:
                self.showRequestLocation()
            case .denied:
                self.showDeniedError()
            case .restricted:
                self.showRestrictedError()
            }
        }
    }
    
    private func showRequestPermission() {
        self.show(.neither) {
            self.locationPermitter.requestPermission() { [weak self] _ in
                self?.findLocationTapped(nil)
            }
        }
    }
    
    // this is turning into a pyramid of doom :(
    private func showRequestLocation() {
        self.places = nil
        self.show(.neither) {
            self.userLocator.requestLocation() { [weak self] result in
                self?.show(.label)
                switch result {
                case .success(let location):
                    self?.configureUI(with: location)
                case .error(let error):
                    self?.configureUI(with: error)
                }
            }
        }
    }
    
    private func configureUI(with location: CLLocation) {
        let coordinate = location.coordinate
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        self.map?.setRegion(region, animated: true)
        self.placeLocator.locateBeer(at: region) { result in
            switch result {
            case .success(let places):
                self.configureUI(with: places)
            case .error(let error):
                self.configureUI(with: error)
            }
        }
    }
    
    private func configureUI(with places: [PlaceLocator.MapItem]) {
        guard places.isEmpty == false else {
            self.updateButtonText(with: "No Beer Found")
            self.show(.button)
            return
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.places = places
            self.updateButtonText(with: "Next")
            self.show(.button)
        }
    }
    
    private func configureUI(with error: Error) {
        self.updateButtonText(with: error.localizedDescription)
        self.show(.button)
    }
    
    private func showDeniedError() {
        self.show(.neither) {
            let vc = self.newDeniedAlert()
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    private func showRestrictedError() {
        self.show(.neither) {
            let vc = self.newRestrictedAlert()
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    private enum Show {
        case button, label, neither
    }
    
    private func show(_ show: Show, completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: 0.3, animations: {
            switch show {
            case .button:
                self.buttonViewConstraint?.constant = self.viewShowConstant
                self.labelViewConstraint?.constant = self.viewHideConstant
            case .label:
                self.buttonViewConstraint?.constant = self.viewHideConstant
                self.labelViewConstraint?.constant = self.viewShowConstant
            case .neither:
                self.buttonViewConstraint?.constant = self.viewHideConstant
                self.labelViewConstraint?.constant = self.viewHideConstant
            }
            self.view.layoutIfNeeded()
        }, completion: { _ in completion?() })
    }
    
    private func newDeniedAlert() -> UIAlertController {
        let alertVC = UIAlertController(title: "Location Denied", message: "Location permissions has been denied. Please open settings to grant location permissions to this app.", preferredStyle: .alert)
        let settings = UIAlertAction(title: "Settings", style: .default) { action in
            self.updateButtonText()
            self.show(.button) {
                let appSettings = URL(string: UIApplicationOpenSettingsURLString)!
                UIApplication.shared.open(appSettings, options: [:], completionHandler: nil)
            }
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { action in
            self.updateButtonText()
            self.show(.button)
        }
        alertVC.addAction(settings)
        alertVC.addAction(cancel)
        return alertVC
    }
    
    private func newRestrictedAlert() -> UIAlertController {
        let alertVC = UIAlertController(title: "Location Restricted", message: "Contact your device administrator to continue using this app.", preferredStyle: .alert)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { action in
            self.updateButtonText()
            self.show(.button)
        }
        alertVC.addAction(cancel)
        return alertVC
    }
}
