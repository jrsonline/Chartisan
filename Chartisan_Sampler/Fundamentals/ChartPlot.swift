//
//  ChartPlot.swift
//  Chartisan_Sampler
//
//  Created by RedPanda on 28-Jul-19.
//  Copyright © 2019 strictlyswift. All rights reserved.
//

import UIKit
import SwiftUI

import Foundation

class ChartPlot<D, Coords: CoordinateSystem> : Identifiable
{
    let id: UUID = UUID()
    
    func render(withCoords coords: Coords, ofSize size: CGSize, for data:[D], scales: PlacedDeterminedScales<Coords.AllowedGuidePlacements>, style: ChartStyle) -> AnyView {
        return EmptyView().asAnyView
    }
    
    func mappingForGuidePlacement(_ placement: Coords.AllowedGuidePlacements) -> [(D) -> Double?] {
        return []
    }
    
    var mergeKey : String? = nil
    
    func merge(plots:[ChartPlot<D, Coords>], blendMode: ChartLayerBlendMode) -> [ChartPlot<D, Coords>] {
        return plots
    }

}
