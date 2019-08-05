//
//  Statistic.swift
//  Chartisan_Sampler
//
//  Created by RedPanda on 28-Jul-19.
//  Copyright © 2019 strictlyswift. All rights reserved.
//

import Foundation

struct Statistic<D,E> {
    let mapping: (D) -> E  // note, need f(x+a) = f(x) + a;  f(b•x) = b•f(x)
}
