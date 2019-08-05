//
//  DoubleAxis.swift
//  Chartisan_Sampler
//
//  Created by RedPanda on 28-Jul-19.
//  Copyright © 2019 strictlyswift. All rights reserved.
//

import UIKit
import SwiftUI

struct YDoubleXLabelAxis: ChartAxis {
    let xscale: LabelScale
    let yscale: DoubleScale
    let format: NumberFormatter? = nil

    func margin() -> (CGSize) -> CGSize {
        { origSize in
            origSize//.trim(by:2)
        }
    }
    
    private func axisPath(_ size: CGSize) -> AnyView {
        let xaxisPosn = size.height * (1 - yscale.interceptPosn())

        return Path { path in
            path.addRect(CGRect(x: 0, y: size.height, width: 2, height: -size.height))
            path.addRect(CGRect(x: 0, y: xaxisPosn, width: size.width, height: 2))
            
            for s in self.yscale.allMajorSteps() {
                let at = CGFloat(s.scaledPosn) * size.height
                path.addRect(CGRect(x: -2, y: size.height-at, width: 4, height: 2))
            }
            
            for s in self.xscale.allMajorSteps() {
                let at = CGFloat(s.scaledPosn) * size.width
                path.addRect(CGRect(x: at, y: xaxisPosn, width: 2, height: 4))
            }
        }
        .fill(Color.primary)
        .asAnyView
    }
    
    private func yAxisScale(_ size: CGSize) -> AnyView {
        ForEach(self.yscale.allMajorSteps()) { t in
            Text("\(dformat(t.value, formatter: self.format))")
                .frame(width: CGFloat(60), alignment: .trailing)
            .position(CGPoint(x:-35, y: size.height * (1 - CGFloat(t.scaledPosn))))
        }
        .asAnyView

    }
    
    private func labelScale(_ size: CGSize) -> AnyView {
        ForEach(self.xscale.allMajorSteps()) { t in
            Text("\(t.value)")
                .allowsTightening(true)
                .frame(width: CGFloat(100), height: CGFloat(t.width) * size.width, alignment: .trailing)
                .rotationEffect(Angle(degrees: 270))
                
            .position(CGPoint(x:CGFloat(t.scaledPosn + 0.5*t.width) * size.width, y:size.height+55))
        }
        .asAnyView
    }
    
    func render(ofSize size: CGSize) -> AnyView {

        return Group {
                axisPath(size)
                yAxisScale(size)
                labelScale(size)
        }
        .frame(width: size.width,  height: size.height)
        .asAnyView
    }
}
