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
    func filterWhereKey(_ isIncluded:(Key) -> Bool) -> Dictionary<Key,Value> {
        return self.filter { isIncluded($0.0) }
    }
    
    func filterWhereValue(_ isIncluded:(Value) -> Bool) -> Dictionary<Key,Value> {
        return self.filter { isIncluded($0.1) }
    }
}

extension CGSize {
    func trim(by: CGFloat) -> CGSize {
        return CGSize(width: self.width - by, height: self.height - by)
    }
}


extension View {
    var asAnyView : AnyView { get { AnyView(self) }}
}

extension String {
    func widthOfString(usingFont font: UIFont) -> CGFloat {
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = self.size(withAttributes: fontAttributes)
        return size.width
    }
}

// Doesn't work, not sure why?
public extension String.StringInterpolation {
    mutating func appendInterpolation<Value:FloatingPoint>(_ value: Value, formatter: NumberFormatter? = nil ) {
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


extension Int {
    var asString: String { get { return "\(self)" }}
    var asDouble: Double { get { return Double(self) }}
}

extension CGFloat {
    var asDouble : Double { get { return Double(self) }}
}

extension Array {
    /// For an array, returns the value at the `idx` element assuming the array was
    /// repeated infinitely.
    /// Eg  for array [1,2,3].loop(2) = 3,  .loop(3) = 1, .loop(4) = 2, .loop(5) = 3, .loop(6) = 1...
    subscript(loop idx: Int) -> Element {
        return self[idx % self.count]
    }
}

extension Array {
    func asIndexedItems() -> [IndexedItem<Element>] {
        return IndexedItem.box(self)
    }
}


extension Font {
    func getUIFont() -> UIFont {
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
    func toSwiftUI(size:CGFloat) -> Font {
        let name = String(self.fontName.dropFirst())  // leading . character ?
        return Font.custom(name, size: size)
    }
}
