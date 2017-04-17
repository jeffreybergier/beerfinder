//
//  FindLocationViewController.swift
//  BeerFinder
//
//  Created by Jeffrey Bergier on 4/16/17.
//  Copyright © 2017 Jeffrey Bergier. All rights reserved.
//

import UIKit
import CoreLocation

class FindLocationViewController: UIViewController {
    
    @IBOutlet private weak var buttonView: UIView?
    @IBOutlet private weak var labelView: UIView?
    
    private var buttonViewConstraint: NSLayoutConstraint?
    private var labelViewConstraint: NSLayoutConstraint?
    
    private let locationManager = CLLocationManager()
    
    private let viewShowConstant: CGFloat = -90
    private let viewHideConstant: CGFloat = 20
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let buttonViewConstant: CGFloat
        let labelViewConstant: CGFloat
        switch CLLocationManager.authorizationStatus() {
        case .authorizedAlways, .authorizedWhenInUse:
            buttonViewConstant = self.viewHideConstant
            labelViewConstant = self.viewShowConstant
        case .denied, .notDetermined, .restricted:
            buttonViewConstant = self.viewShowConstant
            labelViewConstant = self.viewHideConstant
        }
        
        self.buttonViewConstraint = self.buttonView?.topAnchor.constraint(equalTo: self.view.bottomAnchor, constant: buttonViewConstant)
        self.labelViewConstraint = self.labelView?.topAnchor.constraint(equalTo: self.view.bottomAnchor, constant: labelViewConstant)
        
        self.buttonViewConstraint?.isActive = true
        self.labelViewConstraint?.isActive = true
    }
    
    private func findLocation() {
        
    }
    
    private func presentDeniedAlert() {
        let alertVC = UIAlertController(title: "Location Denied", message: "Location permissions has been denied. Please open settings to grant location permissions to this app.", preferredStyle: .alert)
        let settings = UIAlertAction(title: "Settings", style: .default) { action in
        }
        let cancel = UIAlertAction(title: nil, style: .cancel, handler: nil)
        alertVC.addAction(settings)
        alertVC.addAction(cancel)
    }
    
    private func presentRestrictedAlert() {
        
    }
    
    @IBAction private func findLocationTapped(_ sender: NSObject?) {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedAlways, .authorizedWhenInUse:
            self.findLocation()
        case .notDetermined:
            self.locationManager.requestWhenInUseAuthorization()
        case .denied:
            self.presentDeniedAlert()
        case .restricted:
            self.presentRestrictedAlert()
        }
    }
}
