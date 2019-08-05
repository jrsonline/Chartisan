//
//  DoubleScale.swift
//  Chartisan_Sampler
//
//  Created by RedPanda on 28-Jul-19.
//  Copyright © 2019 strictlyswift. All rights reserved.
//

import SwiftUI

struct DoubleScale : ChartScale {
    
    typealias ScaleCalculator = (_ data: [Double]) -> (min: Double, max: Double, steps: Int, stepPositioner: (Int) -> StepPosition<Double>)
    typealias Scaler = (_ min: Double, _ max:Double) -> (_ orig:Double) -> Double
    
    let data: [Double]
    let scaler : Scaler
    let calculator: ScaleCalculator
    let min: Double
    let max: Double
    let steps: Int
    let smallStep: Double = 0.0

    let stepPositioner: (Int) -> StepPosition<Double>
    
    init(_ data: [Double],
         _ calculator: @escaping ScaleCalculator,
         _ scaler: @escaping Scaler,
         _ axisType: ChartAxis.Type = YDoubleXLabelAxis.self) {
        self.data = data
        self.calculator = calculator
        self.scaler = scaler
        (self.min, self.max, self.steps, self.stepPositioner) = calculator(data)
    }
    
    func scale(value: Double) -> CGFloat {
        return CGFloat(scaler(self.min, self.max)(value))
    }
    
    func interceptPosn() -> CGFloat {
        return CGFloat(scaler(self.min, self.max)(0.0))
    }
    
    func allMajorSteps() -> [StepPosition<Double>] {
        return (0..<steps).map (stepPositioner)
    }
//    case linear
//    case log(factor:Double)
//    case broken(break:Double)
//    case polar

    private static let linearScaleCalculator: DoubleScale.ScaleCalculator = { data in
        // create list of steps like... 0.01, 0.02, 0.05, 0.1, 0.2, 0.5, ... 5 million
        let possSteps = zipCombine([1,2,5], Array(-2...6)).map { $0.0 * pow(Double(10),Double($0.1)) }
        
        let (min,max) = (data.min() ?? 0, data.max() ?? 0)
        
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
                return (min: mmin, max: mmax, steps: Int(steps+1),
                        {idx in StepPosition(id: idx,
                                             value:mmin+(mmax-mmin)*(idx.asDouble/steps),
                                             scaledPosn:(idx.asDouble/steps),
                                             width: 1.0/steps)
                }
            )
        }
        }
        
        // Can't create a good scale
        return (min:min, max:max, steps: 10,
                {idx in StepPosition(id: idx,
                                     value:min+(max-min)*(idx.asDouble/10.0),
                                     scaledPosn:(idx.asDouble/10.0),
                                     width: 1.0/10.0)
            } )
    }

    // 0 -> 0
    // min -> -1
    // max -> +1
    
    private static let linearScaler : DoubleScale.Scaler = { min, max in
            return { orig in
                (orig-min)/(max-min)
        }
    }

    static let linear : ([Double]) -> DoubleScale = { data in
        DoubleScale(data, linearScaleCalculator, linearScaler)
    }
}
