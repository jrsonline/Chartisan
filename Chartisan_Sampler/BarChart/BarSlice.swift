//
//  BarSlice.swift
//  Chartisan_Sampler
//
//  Created by RedPanda on 28-Jul-19.
//  Copyright © 2019 strictlyswift. All rights reserved.
//

import SwiftUI

struct BarSlice<D, AllowedGuidePlacement>  {
    let label:String
    let height:(D) -> Double?
    let guide: AllowedGuidePlacement
    let bottom:(D) -> Double
    let width:(D) -> Double
    let dodge:(D) -> Double
    let colour:ChartColour<D>
    
    var top : (D) -> Double? { get {
            return { d in
                if let height = self.height(d) {
                    return self.bottom(d) + height
                } else {
                    return nil
                }
            }
        }
    }
    
    func liftUp(_ f:@escaping (D) -> Double?) -> BarSlice<D, AllowedGuidePlacement> {
        return BarSlice(
            label: self.label,
            height: self.height,
            guide: self.guide,
            bottom: { d in self.bottom(d) + (f(d) ?? 0.0)},
            width: self.width,
            dodge: self.dodge,
            colour: self.colour)
    }
    
    static func compressEvenly(over slices:[BarSlice<D,AllowedGuidePlacement>], factor: Double) -> [BarSlice<D,AllowedGuidePlacement>] {
        var compressedSlices : [BarSlice<D,AllowedGuidePlacement>] = []
        for (n,slice) in slices.enumerated() {
            compressedSlices += [
                BarSlice(label: slice.label,
                         height: slice.height,
                         guide: slice.guide,
                         bottom: slice.bottom,
                         width: {_ in 1.0/Double(slices.count)},
                         dodge: {_ in Double(n)/Double(slices.count)*factor},
                         colour: slice.colour)
            ]
        }
        return compressedSlices
    }
    
    static func blendByLifting(orig xs: [BarSlice<D,AllowedGuidePlacement>], merging x:BarSlice<D,AllowedGuidePlacement>) -> [BarSlice<D,AllowedGuidePlacement>] {
        guard let lastSlice = xs.last else { return [x] }
        
        return xs + [ x.liftUp(lastSlice.top ) ]
    }
    
    static func blend(blendMode: ChartBlendMode, slices: [BarSlice<D,AllowedGuidePlacement>]) -> [BarSlice<D,AllowedGuidePlacement>] {
        switch blendMode {
        case .stack:
            return slices.reduce([]) { xs, x in self.blendByLifting(orig: xs, merging: x) }
        case .dodge:
            return BarSlice.compressEvenly(over: slices, factor: 1.0)
        case .fdodge(let factor):
            return BarSlice.compressEvenly(over: slices, factor: factor)
        default:
            return slices.reduce([]) { xs, x in xs + [x] }
        }
    }
}
