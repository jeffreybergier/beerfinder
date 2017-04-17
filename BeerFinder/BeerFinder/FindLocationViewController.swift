//
//  FindLocationViewController.swift
//  BeerFinder
//
//  Created by Jeffrey Bergier on 4/16/17.
//  Copyright © 2017 Jeffrey Bergier. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class FindLocationViewController: UIViewController {
    
    @IBOutlet private weak var buttonView: UIView?
    @IBOutlet private weak var labelView: UIView?
    @IBOutlet private weak var button: UIButton?
    @IBOutlet fileprivate weak var map: MKMapView?
    
    private var buttonViewConstraint: NSLayoutConstraint?
    private var labelViewConstraint: NSLayoutConstraint?
    
    private let locationManager = CLLocationManager()
    fileprivate var locationError: Error?
    
    private let viewShowConstant: CGFloat = -87
    private let viewHideConstant: CGFloat = 20
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.buttonViewConstraint = self.buttonView?.topAnchor.constraint(equalTo: self.view.bottomAnchor, constant: self.viewShowConstant)
        self.labelViewConstraint = self.labelView?.topAnchor.constraint(equalTo: self.view.bottomAnchor, constant: self.viewHideConstant)
        
        self.buttonViewConstraint?.isActive = true
        self.labelViewConstraint?.isActive = true
        
        self.updateButtonText()
    }
    
    fileprivate func updateButtonText() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedAlways, .authorizedWhenInUse, .notDetermined:
            self.button?.setTitle("Find Location", for: .normal)
        case .denied, .restricted:
            self.button?.setTitle("Location Error", for: .normal)
        }
    }
    
    @IBAction private func findLocationTapped(_ sender: NSObject?) {
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            self.locationManager.requestWhenInUseAuthorization()
        case .authorizedAlways, .authorizedWhenInUse:
            self.show(.neither, preAction: {
                self.locationManager.delegate = self
                self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
                self.locationManager.requestLocation()
            }, postAction: {
                self.show(.label, preAction: nil, postAction: nil)
            })
        case .denied:
            self.show(.neither, preAction: nil) {
                let vc = self.newDeniedAlert()
                self.present(vc, animated: true, completion: nil)
            }
        case .restricted:
            self.show(.neither, preAction: nil) {
                let vc = self.newRestrictedAlert()
                self.present(vc, animated: true, completion: nil)
            }
        }
    }
    
    fileprivate enum Show {
        case button, label, neither
    }
    
    fileprivate func show(_ show: Show, preAction: (() -> Void)?, postAction: (() -> Void)?) {
        preAction?()
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
        }, completion: { _ in postAction?() })
    }
    
    private func newDeniedAlert() -> UIAlertController {
        let alertVC = UIAlertController(title: "Location Denied", message: "Location permissions has been denied. Please open settings to grant location permissions to this app.", preferredStyle: .alert)
        let settings = UIAlertAction(title: "Settings", style: .default) { action in
            self.show(.button, preAction: {
                self.updateButtonText()
            }, postAction: {
                let appSettings = URL(string: UIApplicationOpenSettingsURLString)!
                UIApplication.shared.open(appSettings, options: [:], completionHandler: nil)
            })
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { action in
            self.show(.button, preAction: { self.updateButtonText() }, postAction: nil)
        }
        alertVC.addAction(settings)
        alertVC.addAction(cancel)
        return alertVC
    }
    
    private func newRestrictedAlert() -> UIAlertController {
        let alertVC = UIAlertController(title: "Location Restricted", message: "Contact your device administrator to continue using this app.", preferredStyle: .alert)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { action in
            self.show(.button, preAction: { self.updateButtonText() }, postAction: nil)
        }
        alertVC.addAction(cancel)
        return alertVC
    }
}

extension FindLocationViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let coordinate = locations.first!.coordinate
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        self.map?.setRegion(region, animated: true)
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.show(.button, preAction: {
            self.updateButtonText()
            self.locationError = error
        }, postAction: nil)
    }
}
