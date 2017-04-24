//
//  LilTypes.swift
//  BeerFinder
//
//  Created by Jeffrey Bergier on 4/17/17.
//  Copyright © 2017 Jeffrey Bergier. All rights reserved.
//

import UIKit

enum Result<T> {
    case success(T), error(Error)
}

extension Sequence {
    func first<T>(of _: T.Type) -> T? {
        return first(where: { $0 is T }) as? T
    }
}
