//
//  ChartAxis.swift
//  Chartisan_Sampler
//
//  Created by RedPanda on 28-Jul-19.
//  Copyright © 2019 strictlyswift. All rights reserved.
//

import UIKit
import SwiftUI

protocol ChartAxis {
    func margin() -> (CGSize) -> CGSize
    func render(ofSize size: CGSize) -> AnyView
}




struct StepPosition<V> : Identifiable {
    let id: Int
    let value: V
    let scaledPosn: Double // ie, scaled to [0..1]
    let width: Double // scaled distance from this step to the next, or to '1' if this is the last step
}


protocol ChartHasDouble2Axis {
    func getDouble2MappedData() -> [Double]
}

protocol ChartHasDouble1Axis {
    associatedtype D:Identifiable
    func getDouble1MappedData(for data:[D]) -> [Double]
}

protocol ChartHasLabelAxis {
    func getLabelAxis() -> ChartAxis
}

protocol ChartHasColourScale {
    associatedtype D:Identifiable
    func getColourMappedData(for data:[D]) -> [Double]
}
