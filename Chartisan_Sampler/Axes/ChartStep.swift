//
//  ChartStep.swift
//  Chartisan_Sampler
//
//  Created by RedPanda on 3-Aug-19.
//  Copyright © 2019 strictlyswift. All rights reserved.
//

import SwiftUI


public struct ChartStep : Identifiable, Equatable {

    public let id: Int
    let label: String
    let position: UnitValue
    let width: UnitValue // scaled distance from this step to the next, or to '1' if this is the last step
    
    public static func == (lhs: ChartStep, rhs: ChartStep) -> Bool {
        (lhs.id == rhs.id)
    }
    
}
