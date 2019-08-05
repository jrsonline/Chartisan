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

class ChartPlot<D : Identifiable> : Identifiable
where D.IdentifiedValue == D, D.ID == Int
{
    let id: UUID = UUID()
    
    func render(withCoords coords: CoordinateSystem, ofSize size: CGSize, for data:[IndexedItem<D?>], scales: [GuidePlacement : DeterminedScale]) -> AnyView {
        return EmptyView().asAnyView
    }
    
    func mappingForGuidePlacement(_ placement: GuidePlacement) -> [(D) -> Double] {
        return []
    }
    
    var mergeKey : String? = nil
    
    func merge(plots:[ChartPlot<D>], blendMode: ChartLayerBlendMode) -> [ChartPlot<D>] {
        return plots
    }

}
