//
//  LinearScale.swift
//  Chartisan_Sampler
//
//  Created by RedPanda on 3-Aug-19.
//  Copyright © 2019 strictlyswift. All rights reserved.
//

import Foundation

struct LinearScale : GuideScale {
    var max: Double? = nil
    var min: Double? = nil
    var chartSteps: [ChartStep<Double>] = []
    
    init() {
    }
    /// Merge existing data with new data and mappings
    mutating func mergeData<D>(data: [D?], mappings: [(D) -> Double]) {
        (self.min, self.max, self.chartSteps) = self.computeMaxMinSteps(forData: data, mappings: mappings)
    }
    
    private func computeMaxMinSteps<D>(forData rawData: [D?],  mappings: [(D) -> Double])
    -> (min: Double, max: Double, chartSteps: [ChartStep<Double>])
    {
        // pick out just the data we are interested in (nb, this could be more efficient, not great for very large datasets)
        // if we have multiple mappings for a datapoint, we look at all of them
        let data = rawData.flatMap { (d:D?) -> [Double] in
            if let datum = d {
                return mappings.map { f in f(datum) }
            } else {
                return Array<Double>()
            }
        }
        return self.linearScaleCalculator(data: data, currentMin: self.min, currentMax: self.max)
    }
    
    private func linearScaleCalculator(data: [Double], currentMin: Double?, currentMax: Double?) -> (min: Double, max: Double, chartSteps: [ChartStep<Double>]) {
        // create list of steps like... 0.01, 0.02, 0.05, 0.1, 0.2, 0.5, ... 5 million
        let possSteps = zipCombine([1,2,5], Array(-2...6)).map { $0.0 * pow(Double(10),Double($0.1)) }
        
        let (min,max) = ( fmin(data.min() ?? 0, currentMin ?? 0), fmax(data.max() ?? 0, currentMax ?? 0))
        
        // we need to find a scale which brackets the min,max ; given a step size s, find largest mmin <= min and smallest mmax >= max where s | mmin, s | mmax, and there are <=20 steps of size s between mmin and mmax
        for s in possSteps {
                let mmin : Double = {
                    if max >= 0 && min >= 0 {
                        return 0.0
                    } else {
                        return floor(min/s)*s
                    }
                }()
                
                let mmax : Double = {
                    if max <= 0 && min <= 0 {
                        return 0.0
                    } else {
                        return ceil(max/s)*s
                    }
                }()
                
                let steps = (mmax-mmin) / s
                if steps <= 5 {
                    let chartSteps : [ChartStep<Double>] = (0...Int(steps)).map { idx in
                        ChartStep(id: idx,
                                     value:mmin+(mmax-mmin)*(idx.asDouble/steps),
                                     position:UnitValue(idx.asDouble/steps),
                                     width: UnitValue(1.0/steps))
                    }
                    return (min: mmin,
                            max: mmax,
                            chartSteps: chartSteps)
            }
        }
        
        // Can't create a good scale
        let chartSteps: [ChartStep<Double>] = (0...10).map  { idx in
            ChartStep(id: idx,
                         value:min+(max-min)*(idx.asDouble/10.0),
                         position:UnitValue(idx.asDouble/10.0),
                         width: UnitValue(1.0/10.0))
        }
        return (min:min,
                max:max,
                chartSteps: chartSteps)
    }

    func format(_ value: Double) -> String {
        return dformat(value)
    }
    func interceptPosn() -> UnitValue {
        return self[0.0]
    }
    
    func majorSteps() -> [ChartStep<Double>] {
        return chartSteps
    }
    
    func minorSteps() -> [ChartStep<Double>] {
        return []
    }
    
    subscript(value: Double) -> UnitValue {
        guard let max = self.max, let min = self.min else { fatalError("Scale not properly determined: no min/max")}
        return UnitValue( (value-min)/(max-min) )
    }
    // 0 -> 0
    // min -> -1  IF smaller than 0, else min
    // max -> +1  IF larger than 0, else max
    
    
}
