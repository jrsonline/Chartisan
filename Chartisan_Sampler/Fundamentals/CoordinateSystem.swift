//
//  CoordinateSystem.swift
//  Chartisan_Sampler
//
//  Created by RedPanda on 3-Aug-19.
//  Copyright © 2019 strictlyswift. All rights reserved.
//

import SwiftUI

protocol CoordinateSystem {
    func determineGuideScales<D:Identifiable>(data:[D?], plots: [ChartPlot<D>], labels:[String?]) -> [GuidePlacement : DeterminedScale]
    func drawAxes(chartSize: CGSize, forDeterminedScales scales: [GuidePlacement:DeterminedScale]) -> AnyView
    func drawBox(chartSize: CGSize, at: UnitPoint, size: UnitSize, forScale: GuideScale) -> Path
    func drawLine(chartSize: CGSize, from: UnitPoint, to: UnitPoint, forScale: GuideScale) -> Path
    func place<V:View>(chartSize: CGSize, view:V, at: UnitPoint) -> AnyView
    // add more here, eg annotations, lines of best fit, etc
}
