//
//  LilTypes.swift
//  BeerFinder
//
//  Created by Jeffrey Bergier on 4/17/17.
//  Copyright © 2017 Jeffrey Bergier. All rights reserved.
//

import UIKit

internal enum Result<T> {
    case success(T), error(Error)
}

internal extension Sequence {
    internal func firstWithInferredType<T>() -> T? {
        return self.first(where: { $0 is T }) as? T
    }
}

internal extension UIApplication {
    @discardableResult
    internal func openSettings() -> URL {
        let appSettings = URL(string: UIApplicationOpenSettingsURLString)!
        self.open(appSettings, options: [:], completionHandler: nil)
        return appSettings
    }
}

internal extension UIAlertController {
    internal class func locationDenied(settingsHandler: ((UIAlertAction) -> Void)?, cancelHandler: ((UIAlertAction) -> Void)?) -> UIAlertController {
        let alertVC = UIAlertController(title: "Location Denied",
                                        message: "Location permissions has been denied. Please open settings to grant location permissions to this app.",
                                        preferredStyle: .alert)
        let settings = UIAlertAction(title: "Settings", style: .default, handler: settingsHandler)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: cancelHandler)
        alertVC.addAction(settings)
        alertVC.addAction(cancel)
        return alertVC
    }
    
    internal class func locationRestricted(cancelHandler: ((UIAlertAction) -> Void)?) -> UIAlertController {
        let alertVC = UIAlertController(title: "Location Restricted",
                                        message: "Contact your device administrator to continue using this app.",
                                        preferredStyle: .alert)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: cancelHandler)
        alertVC.addAction(cancel)
        return alertVC
    }
}
