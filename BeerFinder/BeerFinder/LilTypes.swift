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
