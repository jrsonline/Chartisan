//
//  LabelScale.swift
//  Chartisan_Sampler
//
//  Created by RedPanda on 28-Jul-19.
//  Copyright © 2019 strictlyswift. All rights reserved.
//

import Foundation

struct LabelScale {
    let labels: [String]
    let stepPositioner: ([String]) -> (Int) -> StepPosition<String>
    
    static let equallySpaced: ([String]) -> (Int) -> StepPosition<String> = { labels in
        { idx in
            StepPosition(id: idx, value:labels[idx], scaledPosn:Double(idx)/Double(labels.count), width: 1.0/Double(labels.count))
        }
    }
    
    func allMajorSteps() -> [StepPosition<String>] {
        return (0..<(self.labels.count)).map (stepPositioner(self.labels))
    }
    
    static let standard : ([String]) -> LabelScale = { data in
        LabelScale(labels:data, stepPositioner: LabelScale.equallySpaced)
    }
}
