//
//  ChartBlendMode.swift
//  Chartisan_Sampler
//
//  Created by RedPanda on 15-Aug-19.
//  Copyright © 2019 strictlyswift. All rights reserved.
//

import Foundation

public enum ChartBlendMode {
    case none
    case dodge
    case fdodge(Double)
    case stack
    case jitter(Double)
}
