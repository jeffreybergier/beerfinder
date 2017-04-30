//
//  ButtonLabelShowingViewController.swift
//  BeerFinder
//
//  Created by Jeffrey Bergier on 4/23/17.
//  Copyright © 2017 Jeffrey Bergier. All rights reserved.
//

import UIKit

internal class LoaderAndButtonShowingViewController: UIViewController {
    
    @IBOutlet private weak var movingView: UIView?
    @IBOutlet private weak var button: UIButton?
    @IBOutlet private weak var label: UILabel?
    @IBOutlet private weak var buttonParentView: UIView?
    @IBOutlet private weak var labelParentView: UIView?
    
    private var buttonViewConstraint: NSLayoutConstraint?
    
    private var viewShowConstant: CGFloat = -70
    private var viewHideConstant: CGFloat = 20
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let superview = self.parent?.view ?? self.view!
        let frame = self.view.convert(self.view.frame, to: superview)
        let superviewHeight = superview.frame.height
        let distanceFromBottom = superviewHeight - (frame.origin.y + frame.size.height)
        let buttonHeight = self.movingView?.frame.size.height ?? 0
        self.viewShowConstant = -1 * buttonHeight
        self.viewHideConstant = distanceFromBottom
    }
    
    internal override func viewDidLoad() {
        super.viewDidLoad()
    
        self.buttonViewConstraint = self.movingView?.topAnchor.constraint(equalTo: self.view.bottomAnchor, constant: self.viewHideConstant)
        self.buttonViewConstraint?.isActive = true
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
                self.buttonParentView?.alpha = 1
                self.labelParentView?.alpha = 0
            case .loader:
                self.buttonViewConstraint?.constant = self.viewShowConstant
                self.buttonParentView?.alpha = 0
                self.labelParentView?.alpha = 1
            case .neither:
                self.buttonViewConstraint?.constant = self.viewHideConstant
                self.buttonParentView?.alpha = 0
                self.labelParentView?.alpha = 0
            }
            self.view.layoutIfNeeded()
        }, completion: { _ in completion?() })
    }
}

