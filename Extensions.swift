//
//  Extensions.swift
//  Chartisan_Sampler
//
//  Created by RedPanda on 28-Jul-19.
//  Copyright © 2019 strictlyswift. All rights reserved.
//

import UIKit
import SwiftUI

extension Dictionary {
    public func filterWhereKey(_ isIncluded:(Key) -> Bool) -> Dictionary<Key,Value> {
        return self.filter { isIncluded($0.0) }
    }
    
    public func filterWhereValue(_ isIncluded:(Value) -> Bool) -> Dictionary<Key,Value> {
        return self.filter { isIncluded($0.1) }
    }
}

extension CGSize {
    public func trim(by: CGFloat) -> CGSize {
        return CGSize(width: self.width - by, height: self.height - by)
    }
    
    public func transpose(ifRotated: Bool) -> CGSize {
        if ifRotated == false { return self }
        return CGSize(width: self.height, height: self.width)
    }
    
    public func centredIn(_ frame: CGRect) -> CGRect {
        let (fitWidth, fitHeight) = (min(self.width, frame.width), min(self.height, frame.height))
        return CGRect(x: frame.midX - fitWidth / 2.0, y: frame.midY - fitHeight / 2.0, width: fitWidth, height: fitHeight)
    }
}

extension CGSize : Comparable {
    public static func < (lhs: CGSize, rhs: CGSize) -> Bool {
        return (lhs.width*lhs.width + lhs.height*lhs.height) < (rhs.width*rhs.width + rhs.height*rhs.height) 
    }
}

extension View {
    public var asAnyView : AnyView { get { AnyView(self) }}
}

extension String {
    public func sizeOfString(usingFont font: UIFont) -> CGSize {
        let fontAttributes = [NSAttributedString.Key.font: font]
        return self.size(withAttributes: fontAttributes)
    }
}

// Doesn't work, not sure why?
public extension String.StringInterpolation {
    public mutating func appendInterpolation<Value:FloatingPoint>(_ value: Value, formatter: NumberFormatter? = nil ) {
        guard let numValue = value as? NSNumber else { return }
        
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
        
        if let result = withFormatter.string(from: numValue) {
            appendLiteral(result)
        }
    }
}

extension CGRect {
    var center : CGPoint  { get {
            return CGPoint(x:self.midX, y:self.midY)
        }
    }
    
    static func centred(at: CGPoint, size: CGSize) -> CGRect {
        return CGRect(x: at.x - size.width / 2.0, y: at.y - size.height / 2.0, width: size.width, height: size.height)
    }
}

extension Int {
    public var asString: String { get { return "\(self)" }}
    public var asDouble: Double { get { return Double(self) }}
}

extension CGFloat {
    public var asDouble : Double { get { return Double(self) }}
}

extension Array {
    /// For an array, returns the value at the `idx` element assuming the array was
    /// repeated infinitely.
    /// Eg  for array [1,2,3].loop(2) = 3,  .loop(3) = 1, .loop(4) = 2, .loop(5) = 3, .loop(6) = 1...
    public subscript(loop idx: Int) -> Element {
        return self[idx % self.count]
    }
}

extension Array {
    public func asIndexedItems() -> [IndexedItem<Element>] {
        return IndexedItem.box(self)
    }
}


extension Font {
    public func getUIFont() -> UIFont {
        switch self {
            case .body: return UIFont.preferredFont(forTextStyle: .body)
            case .title: return UIFont.preferredFont(forTextStyle: .title1)
            case .largeTitle: return UIFont.preferredFont(forTextStyle: .largeTitle)
            case .headline: return UIFont.preferredFont(forTextStyle: .headline)
            case .subheadline: return UIFont.preferredFont(forTextStyle: .subheadline)
            case .callout: return UIFont.preferredFont(forTextStyle: .callout)
            case .caption: return UIFont.preferredFont(forTextStyle: .caption1)
            case .footnote: return UIFont.preferredFont(forTextStyle: .footnote)
            default: return UIFont.preferredFont(forTextStyle: .body)
        }
 
    }
}

extension UIFont {
    public func toSwiftUI(size:CGFloat) -> Font {
        let name = String(self.fontName.dropFirst())  // leading . character ?
        return Font.custom(name, size: size)
    }
}
