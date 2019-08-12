//
//  Scales-Protocols.swift
//  Chartisan_Sampler
//
//  Created by RedPanda on 3-Aug-19.
//  Copyright © 2019 strictlyswift. All rights reserved.
//

import Foundation

protocol MeasurableScale {
    func majorSteps() -> [ChartStep]
    func interceptPosn() -> UnitValue
}

protocol GuideScale : MeasurableScale {
    init()
    mutating func mergeData<D>(data:[D], mappings:[(D) -> Double?])
    func format(_ value: Double) -> String
    func minorSteps() -> [ChartStep]
    subscript(value:Double) -> UnitValue {get}
}

protocol LabelsScale : MeasurableScale {
    init(labels: [String?])
    subscript(idx:Int) -> String? {get}
}


