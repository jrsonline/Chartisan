//
//  UnitValue.swift
//  Chartisan_Sampler
//
//  Created by RedPanda on 3-Aug-19.
//  Copyright © 2019 strictlyswift. All rights reserved.
//

import Foundation
import UIKit

/// Value used to indicate that a number is between -1 and 1
struct UnitValue {
    static let zero = UnitValue(0)
    static let one = UnitValue(1)
    static let minusOne = UnitValue(-1)
    private var _value : Double
    init(_ value: Double) {
        guard  fabs(value)<=1 else {fatalError("Unit value  must be -1<=value<=1, got \(value)")}
        self._value = value
    }
    var value: Double { get { return _value }}
    
    /// Returns 1.0 - value.
    var inverse: UnitValue { get { return Self(1.0-_value) }}
    
    func factor<N:BinaryFloatingPoint>(by: N) -> N {
        return N(self.value) * by
    }
    
    static func-<N:BinaryFloatingPoint>(a:N, b: UnitValue) -> N {
        return a - N(b.value)
    }
    static func-<N:BinaryFloatingPoint>(a:UnitValue, b: N) -> N {
        return N(a.value) - b
    }
    static func-(a:UnitValue, b: UnitValue) -> Double {
        return a.value - b.value
    }
    static func+<N:BinaryFloatingPoint>(a:N, b: UnitValue) -> N {
        return a + N(b.value)
    }
    static func+<N:BinaryFloatingPoint>(a:UnitValue, b: N) -> N {
        return N(a.value) + b
    }
    static func+(a:UnitValue, b: UnitValue) -> Double {
        return a.value + b.value
    }
    static func*<N:BinaryFloatingPoint>(a:N, b: UnitValue) -> N {
        return a * N(b.value)
    }
    static func*<N:BinaryFloatingPoint>(a:UnitValue, b: N) -> N {
        return N(a.value) * b
    }
    static func*(a:UnitValue, b: UnitValue) -> Double {
        return a.value * b.value
    }
    
    func clamped<N:BinaryFloatingPoint>(add v: N) -> UnitValue {
        let v = max(-1.0, min(1.0, Double(v) + self._value))
        return UnitValue( v )
    }
}
/// Like a CGPoint but the points are constrained to -1<=x<=1
struct UnitPoint {
    private var _point : CGPoint
    init(_ x: UnitValue,_ y: UnitValue) {
        self._point = CGPoint(x:x.value, y:y.value)
    }
    init(_ x: Double,_ y: Double) {
        guard  fabs(x)<=1 else {fatalError("Point value x must be -1<=x<=1")}
        guard  fabs(y)<=1 else {fatalError("Point value y must be -1<=y<=1")}
        self._point = CGPoint(x:x, y:y)
    }
    var point: CGPoint { get { return _point }}
    
    static let zero = UnitPoint(0.0, 0.0)
}

/// Like a CGSize but height/width are constrained to 0<=x<=1
struct UnitSize {
    private var _size : CGSize
    init(width: UnitValue, height: UnitValue) {
        self._size = CGSize(width:width.value, height:height.value)
    }
    init(width: Double, height: Double) {
        guard  width>=0 && width<=1 else {fatalError("Width must be 0<=width<=1")}
        guard  height>=0 && height<=1 else {fatalError("Height must be 0<=height<=1")}
        self._size = CGSize(width:width, height:height)
    }
    var size: CGSize { get { return _size }}
    
    static let zero = UnitSize(width:0.0, height:0.0)
}
