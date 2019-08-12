//
//  AllLabelsScale.swift
//  Chartisan_Sampler
//
//  Created by RedPanda on 3-Aug-19.
//  Copyright © 2019 strictlyswift. All rights reserved.
//

import Foundation

struct AllLabelScale: LabelsScale {

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

    func interceptPosn() -> UnitValue {
        return UnitValue.zero
    }
    
    subscript(idx: Int) -> String? {
        return labels[idx]
    }
    
    
}
