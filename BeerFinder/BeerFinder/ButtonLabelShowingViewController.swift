//
//  ButtonLabelShowingViewController.swift
//  BeerFinder
//
//  Created by Jeffrey Bergier on 4/23/17.
//  Copyright © 2017 Jeffrey Bergier. All rights reserved.
//

import UIKit

internal class LoaderAndButtonShowingViewController: UIViewController {
    
    @IBOutlet private weak var buttonView: UIView?
    @IBOutlet private weak var loadingView: UIView?
    @IBOutlet private weak var button: UIButton?
    @IBOutlet private weak var label: UILabel?
    
    private var buttonViewConstraint: NSLayoutConstraint?
    private var loadingViewConstraint: NSLayoutConstraint?
    
    private let viewShowConstant: CGFloat = -84
    private let viewHideConstant: CGFloat = 12
    
    internal override func viewDidLoad() {
        super.viewDidLoad()
    
        self.buttonViewConstraint = self.buttonView?.topAnchor.constraint(equalTo: self.view.bottomAnchor, constant: self.viewHideConstant)
        self.loadingViewConstraint = self.loadingView?.topAnchor.constraint(equalTo: self.view.bottomAnchor, constant: self.viewHideConstant)
        self.buttonViewConstraint?.isActive = true
        self.loadingViewConstraint?.isActive = true
    }
    
    internal func setLoader(text: String) {
        self.label?.text = text
    }
    
    internal func setButton(text: String) {
        self.button?.setTitle(text, for: .normal)
    }
    
    internal enum Show {
        case button, loader, neither
    }
    
    internal func updateUI(_ show: Show, completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: 0.3, animations: {
            switch show {
            case .button:
                self.buttonViewConstraint?.constant = self.viewShowConstant
                self.loadingViewConstraint?.constant = self.viewHideConstant
            case .loader:
                self.buttonViewConstraint?.constant = self.viewHideConstant
                self.loadingViewConstraint?.constant = self.viewShowConstant
            case .neither:
                self.buttonViewConstraint?.constant = self.viewHideConstant
                self.loadingViewConstraint?.constant = self.viewHideConstant
            }
            self.view.layoutIfNeeded()
        }, completion: { _ in completion?() })
    }
    
    internal var buttonTapped: (() -> Void)?
    
    @IBAction private func buttonTapped(_ sender: NSObject?) {
        self.buttonTapped?()
    }
    
}

