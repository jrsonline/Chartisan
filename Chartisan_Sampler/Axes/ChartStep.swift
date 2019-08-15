//
//  ChartStep.swift
//  Chartisan_Sampler
//
//  Created by RedPanda on 3-Aug-19.
//  Copyright © 2019 strictlyswift. All rights reserved.
//

import SwiftUI


struct ChartStep : Identifiable {
    let id: Int
    let label: String
    let position: UnitValue
    let width: UnitValue // scaled distance from this step to the next, or to '1' if this is the last step
}
