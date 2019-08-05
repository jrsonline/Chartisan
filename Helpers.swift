//
//  Helpers.swift
//  Chartisan_Sampler
//
//  Created by RedPanda on 28-Jul-19.
//  Copyright © 2019 strictlyswift. All rights reserved.
//

import SwiftUI

struct IndexedItem<A> : Identifiable {
    let id: Int
    let dt: A
    
    static func box(_ data:[A]) -> [IndexedItem<A>] {
        zip(0...,data).map(IndexedItem.init)
    }
    
    static func addTo(_ data:[IndexedItem<A>], item:A) -> [IndexedItem<A>] {
        return data + [IndexedItem(id: data.count, dt: item)]
    }
}


/// Like 'zip' but creates all possible combinations of `aas` and `bbs` ; eg `zipCombine([a,b,c],[1,2]) = ([a,1],[b,1],[c,1],[a,2],[b,2],[c,2])`
///
/// Note that the _first_ (`aas`) array cycles fastest.
func zipCombine<A,B>(_ aas:[A], _ bbs:[B]) -> [(A,B)] {
    var combination : [(A,B)] = []
    for b in bbs {
        for a in aas {
            combination += [(a,b)]
        }
    }
    return combination
}


func dformat(_ value: Double, formatter: NumberFormatter? = nil ) -> String {
    let withFormatter: NumberFormatter
    if formatter == nil {
        // Set up a reasonable default
        withFormatter = NumberFormatter()
        withFormatter.numberStyle = .decimal
        withFormatter.alwaysShowsDecimalSeparator = false
        withFormatter.maximumFractionDigits = 2
    } else {
        withFormatter = formatter!
    }
    
    if let result = withFormatter.string(from: value as NSNumber) {
        return result
    } else {
        return ""
    }
}

func infinite<A>(_ value:A) -> AnySequence<A> {
    return AnySequence { () -> AnyIterator<A> in
        AnyIterator {
            value
        }
    }
}

