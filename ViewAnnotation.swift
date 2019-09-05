//
//  ViewAnnotation.swift
//  Chartisan_Sampler
//
//  Created by RedPanda on 1-Sep-19.
//  Copyright © 2019 strictlyswift. All rights reserved.
//

import SwiftUI

public class ViewAnnotation : CustomStringConvertible {
    var annotations: [String:Any] = [:]
    
    subscript(v: String) -> Any? {
        get { return annotations[v] }
        set { self.annotations[v] = newValue }
    }
    
    public var description: String { get { return self.annotations.description }}
    
    static var debug : ViewAnnotation = ViewAnnotation()
}

struct ViewAnnotationKey : EnvironmentKey {
    public static let defaultValue: ViewAnnotation? = nil
}

extension EnvironmentValues {
    var viewAnnotation : ViewAnnotation? {
        get { self[ViewAnnotationKey.self] }
        set { self[ViewAnnotationKey.self] = newValue }
    }
}

protocol FrameReportingView {
    var frames: [String:CGRect] { get }
}



