//
//  ChartSections.swift
//  Chartisan_Sampler
//
//  Created by RedPanda on 22-Aug-19.
//  Copyright © 2019 strictlyswift. All rights reserved.
//

import Foundation
import CoreGraphics

public struct ChartSections<GuidePlacement:Hashable> {
    let plotArea: CGRect
    let titleArea: CGRect
    let keyAreas: [CGRect]
    let guidePlacementAreas: [GuidePlacement:CGRect]
}
