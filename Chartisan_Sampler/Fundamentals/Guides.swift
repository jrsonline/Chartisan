//
//  Guides.swift
//  Chartisan_Sampler
//
//  Created by RedPanda on 3-Aug-19.
//  Copyright © 2019 strictlyswift. All rights reserved.
//

import Foundation


enum DeterminedScale {
    case labelScale(LabelsScale)
    case guideScale(GuideScale)
    
    func getGuideScale() -> GuideScale? {
        switch self {
            case .guideScale(let g): return g
            default: return nil
        }
    }
    func getLabelScale() -> LabelsScale? {
        switch self {
            case .labelScale(let l): return l
            default: return nil
        }
    }
    
    func getMeasurableScale() -> MeasurableScale {
        switch self {
            case .labelScale(let labelScale): return labelScale as MeasurableScale
            case .guideScale(let guideScale): return guideScale as MeasurableScale
        }
    }
}

typealias PlacedDeterminedScales<P:Hashable> = [P : (DeterminedScale,String)]

enum GuidePlacement {
    case xAxis, yAxis, x2ndAxis, y2ndAxis, polarAxis, zAxis // etc
}
