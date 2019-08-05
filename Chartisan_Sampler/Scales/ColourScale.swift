//
//  ColourScale.swift
//  Chartisan_Sampler
//
//  Created by RedPanda on 28-Jul-19.
//  Copyright © 2019 strictlyswift. All rights reserved.
//

import Foundation
import SwiftUI

enum ChartColour<D> {
    case stripe(Color, Color)
    case stripeAll([Color])
    case fixed(Color)
    case flag(KeyPath<D,Bool>, ifTrue:Color, ifFalse:Color)
//    case posNeg(value:(D) -> Double, pos:Color, neg:Color)
    case posNeg(KeyPath<D,Double>, pos:Color, neg:Color)
 //   case top(Int, in:Color, out:Color)   TODO
    case custom((Int, D) -> Color)

    func colourFor(idx: Int?, datum: D?) -> Color {
        guard let idx = idx, let datum = datum else { return Color.clear }
        switch self {
            case let .stripe(c1,c2): return [c1,c2][loop:idx]
            case let .stripeAll(cs): return cs[loop:idx]
            case let .fixed(c): return c
//            case let .posNeg(value: value, pos: posCol, neg: negCol): if value(datum) < 0 { return negCol} else { return posCol }
            case let .posNeg(path, pos: posCol, neg: negCol): if datum[keyPath:path] < 0 { return negCol} else { return posCol }
            case let .custom(f): return f(idx, datum)
            case let .flag(path, ifTrue, ifFalse): if datum[keyPath:path] { return ifTrue } else { return ifFalse }
            
        }
    }
}


struct ColourScale {
    let baseData: [Double]
    let stripeCount : Int
    let colourCalculator: ([Double],Int) -> (_ col:Double, _ stripe: Int, _ idx:Int) -> Color
    
     

    func colour(col: Double, slice: Int, idx:Int) -> Color {
        return colourCalculator(self.baseData, self.stripeCount)(col, slice, idx)   // needs more work to produce key
    }
    
    static func sameColourScaleCalculator(_ c:Color) -> ([Double],Int) -> (_ col:Double, _ stripe: Int, _ idx:Int) -> Color { {_, _ in
            return  { _,_,_ in c }
        }
    }
    
    static func same(_ colour: Color = .red) -> ([Double],Int) -> ColourScale {
    { data, stripeCount in
        ColourScale(baseData: data, stripeCount: stripeCount, colourCalculator: ColourScale.sameColourScaleCalculator(colour))
        }
    }
    
    static func stripesCalculator(_ colours: [Color]) -> ([Double],Int) -> (_ col:Double, _ stripe: Int, _ idx:Int) -> Color {
        return {_, stripeCount in
            { _, stripe, idx in
                let colsPerStripe = (colours.count/stripeCount)
                let stripeIndex = idx % colsPerStripe
                return  colours[loop: colsPerStripe*stripe + stripeIndex]
            }
        }
    }
    
    static func stripes(_ colours: [Color]) -> ([Double],Int) -> ColourScale {
    { data, stripeCount in
        ColourScale(baseData: data, stripeCount: stripeCount, colourCalculator: ColourScale.stripesCalculator(colours))
        }
    }
    
    static func stripes(_ colours: Color...) ->  ([Double],Int) -> ColourScale {
        return stripes(colours)
    }
    
    static func multi() -> ([Double], Int) -> ColourScale {
        return stripes( .red, .green, .blue, .yellow,.gray, .orange, .purple, .pink)
    }
    
    static func perSliceCalculator(_ colours: [Color]) -> ([Double],Int) -> (_ col:Double, _ stripe: Int, _ idx:Int) -> Color {
        return {_, stripeCount in
            { _, stripe, _ in
                return  colours[loop: stripe]
            }
        }
    }
    
    static func perSlice(_ colours: [Color]) -> ([Double], Int) -> ColourScale {
    { data, stripeCount in
        ColourScale(baseData: data, stripeCount: stripeCount, colourCalculator: ColourScale.perSliceCalculator(colours))
        }
    }
    
    static func perSlice(_ colours: Color...) -> ([Double], Int) -> ColourScale {
        return perSlice(colours)
    }

    
    static func negPosCalculator(posColour: Color, negColour: Color) -> ([Double],Int) -> (_ col:Double, _ stripe: Int, _ idx:Int) -> Color {
        return { _,_ in
            return { col, _, _ in col < 0 ? negColour : posColour }
        }
    }
    
    static func negPos(posColour: Color, negColour: Color = .red) -> ([Double], Int) -> ColourScale {
    { data, stripeCount in
        ColourScale(baseData: data, stripeCount: stripeCount, colourCalculator: ColourScale.negPosCalculator(posColour: posColour, negColour: negColour))
        }
    }
}
 
