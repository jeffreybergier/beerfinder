//
//  UserDefaults.swift
//  BeerFinder
//
//  Created by Jeffrey Bergier on 5/4/17.
//  Copyright © 2017 Jeffrey Bergier. All rights reserved.
//

import Foundation

internal extension UserDefaults {
    
    private enum Keys {
        static let kSearchTermKey = "kSearchTermKey"
    }
    
    internal var searchTerm: String {
        get {
            return self.string(forKey: Keys.kSearchTermKey)!
        }
        set {
            self.set(newValue, forKey: Keys.kSearchTermKey)
        }
    }
    
    internal func configure() {
        self.register(defaults: [Keys.kSearchTermKey : "bar"])
    }
}
