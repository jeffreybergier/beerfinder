//
//  HardModeViewController.swift
//  BeerFinder
//
//  Created by Jeffrey Bergier on 4/26/17.
//  Copyright © 2017 Jeffrey Bergier. All rights reserved.
//

import UIKit

class HardModeViewController: UIViewController {
    
    @IBOutlet private weak var blurView: UIVisualEffectView?
    private let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.light)
    
    internal override func viewDidLoad() {
        super.viewDidLoad()
        self.blurView?.effect = nil
    }
    
    @IBAction private func hardModeToggled(_ sender: NSObject?) {
        guard let sender = sender as? UISwitch else { return }
        UIView.animate(withDuration: 0.3) {
            switch sender.isOn {
            case true:
                self.blurView?.effect = self.blurEffect
            case false:
                self.blurView?.effect = nil
            }
        }
    }
    
}
