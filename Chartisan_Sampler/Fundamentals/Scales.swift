//
//  Scales-Protocols.swift
//  Chartisan_Sampler
//
//  Created by RedPanda on 3-Aug-19.
//  Copyright © 2019 strictlyswift. All rights reserved.
//

import Foundation

public protocol MeasurableScale {
    func majorSteps() -> [ChartStep]
    func interceptPosn() -> UnitValue
    func centreTextBetweenSteps() -> Bool
    func reverseLabelsHint() -> Bool
    func majorStepWidth() -> UnitValue
}

public protocol GuideScale : MeasurableScale {
    init()
    mutating func mergeData<D>(data:[D], mappings:[(D) -> Double?])
    func format(_ value: Double) -> String
    func minorSteps() -> [ChartStep]
    subscript(value:Double) -> UnitValue {get}
}

public protocol TextScale : MeasurableScale {
    init(labels: [String?])
    subscript(idx:Int) -> String? {get}
}


