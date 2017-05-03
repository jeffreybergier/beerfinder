//
//  ButtonLabelShowingViewController.swift
//  BeerFinder
//
//  Created by Jeffrey Bergier on 4/23/17.
//  Copyright © 2017 Jeffrey Bergier. All rights reserved.
//

import UIKit

internal class LoaderAndButtonShowingViewController: UIViewController {
    
    @IBOutlet private weak var button: UIButton?
    @IBOutlet private weak var label: UILabel?
    @IBOutlet private weak var buttonParentView: UIView?
    @IBOutlet private weak var labelParentView: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.updateUI(.button, animationDuration: 0.0, completion: nil)
    }
    
    internal func setLoader(text: String) {
        self.label?.text = text
    }
    
    internal func setButton(text: String) {
        // UIButton is really insistent on animating its label change
        // this stops that
        UIView.animate(withDuration: 0.0) {
            self.button?.setTitle(text, for: .normal)
        }
    }
    
    internal enum Show {
        case button, loader, neither
    }
    
    internal func updateUI(_ show: Show, animationDuration: TimeInterval = 0.3, completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: animationDuration, animations: {
            switch show {
            case .button:
                self.button?.isEnabled = true
                self.buttonParentView?.alpha = 1
                self.labelParentView?.alpha = 0
            case .loader:
                self.button?.isEnabled = false
                self.buttonParentView?.alpha = 0
                self.labelParentView?.alpha = 1
            case .neither:
                self.button?.isEnabled = false
                self.buttonParentView?.alpha = 0
                self.labelParentView?.alpha = 0
            }
            self.view.layoutIfNeeded()
        }, completion: { _ in completion?() })
    }
}

