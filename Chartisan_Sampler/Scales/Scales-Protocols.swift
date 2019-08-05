//
//  Scales-Protocols.swift
//  Chartisan_Sampler
//
//  Created by RedPanda on 3-Aug-19.
//  Copyright © 2019 strictlyswift. All rights reserved.
//

import Foundation

protocol GuideScale {
    init()
    mutating func mergeData<D>(data:[D], mappings:[(D) -> Double?])
    func format(_ value: Double) -> String
    func interceptPosn() -> UnitValue
    func majorSteps() -> [ChartStep<Double>]
    func minorSteps() -> [ChartStep<Double>]
    subscript(value:Double) -> UnitValue {get}
}

protocol LabelsScale {
    init(labels: [String?])
    func majorSteps() -> [ChartStep<String?>]
    subscript(idx:Int) -> String? {get}
}


