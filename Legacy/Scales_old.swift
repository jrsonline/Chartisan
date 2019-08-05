//
//  Scales.swift
//  Chartisan_Sampler
//
//  Created by RedPanda on 28-Jul-19.
//  Copyright © 2019 strictlyswift. All rights reserved.
//

import SwiftUI

struct Scales {
    let xDoubleScale: (([Double]) -> DoubleScale )?
    let yDoubleScale: (([Double]) -> DoubleScale )?
    let xLabelScale: (([String]) -> LabelScale )?
    let yLabelScale: (([String]) -> LabelScale )?
    let colourScale: (([Double],Int) -> ColourScale )?
    
    init(
        xDoubleScale: (([Double]) -> DoubleScale )? = nil,
        yDoubleScale: (([Double]) -> DoubleScale )? = DoubleScale.linear,
        xLabelScale: (([String]) -> LabelScale )? = LabelScale.standard,
        yLabelScale: (([String]) -> LabelScale )? = nil,
        colourScale: (([Double],Int) -> ColourScale )? = ColourScale.multi()
        ) {
        self.xDoubleScale = xDoubleScale
        self.yDoubleScale = yDoubleScale
        self.xLabelScale = xLabelScale
        self.yLabelScale = yLabelScale
        self.colourScale = colourScale
    }
}

class ComputedScales {
    var xDoubleComputedScale: DoubleScale? = nil
    var yDoubleComputedScale: (DoubleScale )? = nil
    var xLabelComputedScale: ( LabelScale )? = nil
    var yLabelComputedScale: ( LabelScale )? = nil
    var colourComputedScale: ( ColourScale )? = nil
}
