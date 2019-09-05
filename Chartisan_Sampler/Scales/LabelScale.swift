//
//  AllLabelsScale.swift
//  Chartisan_Sampler
//
//  Created by RedPanda on 3-Aug-19.
//  Copyright © 2019 strictlyswift. All rights reserved.
//

import Foundation

struct LabelScale: TextScale, Equatable {
    let labels : [String?]
    let labelSteps : [ChartStep]
    
    init(labels: [String?]) {
        self.labels = labels
        
        self.labelSteps = self.labels.enumerated().map { arg in
            let (idx, label) = arg
            return ChartStep(id:idx,
                             label: label ?? "",
                             position: UnitValue(idx.asDouble / labels.count.asDouble),
                             width: UnitValue(1.0 / labels.count.asDouble))
        }
    }

    func majorSteps() -> [ChartStep] {
        return labelSteps
    }
    
    func reverseLabelsHint() -> Bool {
        true
    }
    
    func centreTextBetweenSteps() -> Bool {
        true
    }
    
    func majorStepWidth() -> UnitValue {
        return UnitValue(1.0/labelSteps.count.asDouble)
    }

    func interceptPosn() -> UnitValue {
        return UnitValue.zero
    }
    
    subscript(idx: Int) -> String? {
        return labels[idx]
    }
    
    static func == (lhs: LabelScale, rhs: LabelScale) -> Bool {
        (lhs.labels == rhs.labels) && (lhs.labelSteps == rhs.labelSteps)
    }
    
}
