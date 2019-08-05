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
}

enum GuidePlacement {
    case xAxis, yAxis, x2ndAxis, y2ndAxis, polarAxis, zAxis // etc
}
