//
//  ChartStyle.swift
//  Chartisan_Sampler
//
//  Created by RedPanda on 12-Aug-19.
//  Copyright © 2019 strictlyswift. All rights reserved.
//

import SwiftUI

public struct ChartStyle {
    let labelFont : UIFont
    let labelFontColour : Color
    let numberFormatter: (_ value: Double, _ formatter: NumberFormatter) -> String

    public init(
        labelFont : UIFont = Font.body.getUIFont(),
        labelFontColour : Color = .primary,
        numberFormatter: @escaping (_ value: Double, _ formatter: NumberFormatter) -> String = dformat) {
        self.labelFont = labelFont
        self.labelFontColour = labelFontColour
        self.numberFormatter = numberFormatter
    }
    
    
    
}
