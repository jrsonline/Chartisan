//
//  LabelAxis.swift
//  Chartisan_Sampler
//
//  Created by RedPanda on 28-Jul-19.
//  Copyright © 2019 strictlyswift. All rights reserved.
//


import UIKit
import SwiftUI

struct LabelAxis: ChartAxis {
    let scale: LabelScale
  //  let format: NumberFormatter? = nil

    func margin() -> (CGSize) -> CGSize {
        { origSize in
            origSize//.trim(by:2)
        }
    }
    
    func render(ofSize size: CGSize) -> AnyView {
        return Group {
                Path { path in
                    path.addRect(CGRect(x: 0, y: size.height, width: 2, height: -size.height))
                    path.addRect(CGRect(x: 0, y: size.height * (1 - scale.interceptPosn()), width: size.width, height: 2))
                    
                    for s in self.scale.allMajorSteps() {
                        let at = CGFloat(s.scaledPosn) * size.height
                        path.addRect(CGRect(x: -2, y: size.height-at, width: 4, height: 2))
                    }
                }.fill(Color.primary)
                    ForEach(self.scale.allMajorSteps()) { t in
                        Text("\(dformat(t.value, formatter: self.format))")
                            .frame(width: 60, alignment: .trailing)
                        .position(CGPoint(x:-35, y: size.height * (1 - CGFloat(t.scaledPosn))))
                    
                }//.offset(CGSize(width:-size.width/2, height:0))
            }
            .frame(width: size.width,  height: size.height)
            .asAnyView
    }
}
