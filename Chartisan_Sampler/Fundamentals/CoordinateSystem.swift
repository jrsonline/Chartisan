//
//  CoordinateSystem.swift
//  Chartisan_Sampler
//
//  Created by RedPanda on 3-Aug-19.
//  Copyright © 2019 strictlyswift. All rights reserved.
//

import SwiftUI

protocol CoordinateSystem {
    associatedtype AllowedGuidePlacements:Hashable
    func determineGuideScales<D>(data:[D], plots: [ChartPlot<D, Self>], labels:[String?]) -> PlacedDeterminedScales<AllowedGuidePlacements>
    func drawAxes(chartSize: CGSize, forDeterminedScales scales: PlacedDeterminedScales<AllowedGuidePlacements>) -> AnyView
    func drawBox(chartSize: CGSize, at: UnitPoint, size: UnitSize, forScale: GuideScale, on: AllowedGuidePlacements) -> Path
    func drawLine(chartSize: CGSize, from: UnitPoint, to: UnitPoint, forScale: GuideScale, on: AllowedGuidePlacements) -> Path
    func place<V:View>(chartSize: CGSize, view:V, at: UnitPoint) -> AnyView
    // add more here, eg annotations, lines of best fit, etc
}
