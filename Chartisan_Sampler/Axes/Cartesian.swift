//
//  Cartesian.swift
//  Chartisan_Sampler
//
//  Created by RedPanda on 30-Jul-19.
//  Copyright © 2019 strictlyswift. All rights reserved.
//

import SwiftUI

enum CartesianAxisType {
    case labels(LabelsScale.Type)
    case guide(GuideScale.Type)
    case none
    
    func getGuideScaleType() -> GuideScale.Type? {
        switch self {
            case .guide(let g): return g
            default: return nil
        }
    }
    func getLabelScaleType() -> LabelsScale.Type? {
        switch self {
            case .labels(let l): return l
            default: return nil
        }
    }
}

extension CartesianAxisType {
    static let linearGuide = CartesianAxisType.guide(LinearScale.self )
    static let allLabels = CartesianAxisType.labels(AllLabelScale.self )
}

extension UnitPoint {
    func toCartesian(ofSize size: CGSize) -> CGPoint {
        return CGPoint(x: point.x * size.width, y: size.height * (1 - point.y) )
    }
}

extension UnitSize {
    func toCartesian(ofSize factor: CGSize) -> CGSize {
        return CGSize(width: size.width * factor.width, height: size.height * factor.height )
    }
}

enum CartesianAxisPlacement {
    case xAxis
    case yAxis
    case x2ndAxis
    case y2ndAxis
    
    /// CartesianAxisPlacement is the specialized type for Cartesian axes. We need to be able to map to the broader GuidePlacement
    func toGuidePlacement() -> GuidePlacement {
        switch self {
            case .xAxis: return .xAxis
            case .yAxis: return .yAxis
            case .x2ndAxis: return .x2ndAxis
            case .y2ndAxis: return .y2ndAxis
        }
    }
}


extension GuidePlacement {
    func isCartesian() -> Bool {
        switch self {
            case .xAxis, .yAxis, .x2ndAxis, .y2ndAxis: return true
            default: return false
        }
    }
}

struct Cartesian : CoordinateSystem {
    let axes: [CartesianAxisPlacement : CartesianAxisType]
    
    /// Figure out the scales given the axes requested, and the plots

    func determineGuideScales<D>(data: [D?], plots: [ChartPlot<D>], labels: [String?]) ->
        [GuidePlacement : DeterminedScale]
        where D : Identifiable
    {
        var chartGuideDeterminedScale : [GuidePlacement : DeterminedScale] = [:]
        
        for cartesianScaleType in axes {
            let placement = cartesianScaleType.key.toGuidePlacement()
            
            switch cartesianScaleType.value {
                
                case .guide(let guideScaleType):
                    var guideScale = guideScaleType.init()
                    for plot in plots {
                        guideScale.mergeData(data: data, mappings: plot.mappingForGuidePlacement(placement) )
                    }
                    chartGuideDeterminedScale[placement] = .guideScale(guideScale)
                    
                case .labels(let labelScaleType):
                    let labelScale = labelScaleType.init(labels: labels)
                    chartGuideDeterminedScale[placement] = .labelScale( labelScale )
                    
                default:
                    break
                }
        }
        
        return chartGuideDeterminedScale
    }
    

    private func drawAxisPath(size: CGSize, scales: [GuidePlacement:DeterminedScale]) -> AnyView {
        // for now
        let scale = scales[.yAxis]!.getGuideScale()!
        
        let xaxisPosn = scale.interceptPosn().inverse.factor(by: size.height)

        return Path { path in
            path.addRect(CGRect(x: 0, y: size.height, width: 2, height: -size.height))
            path.addRect(CGRect(x: 0, y: xaxisPosn, width: size.width, height: 2))
            
            for s in scale.majorSteps() {
                let at = s.position.factor(by: size.height)
                path.addRect(CGRect(x: -2, y: size.height-at, width: 4, height: 2))
            }
        }
        .fill(Color.primary)
        .asAnyView
    }
    
    private func drawGuideScale(size: CGSize, scales: [GuidePlacement:DeterminedScale]) -> AnyView {
        let scale = scales[.yAxis]!.getGuideScale()!

        return ForEach(scale.majorSteps()) { t in
            Text("\(scale.format(t.value))")
                .allowsTightening(true)
                .minimumScaleFactor(0.25)
                .frame(width: CGFloat(60), alignment: .trailing)
                .position(CGPoint(x:-35, y: t.position.inverse.factor(by:size.height) ) )
        }
        .asAnyView

    }

    
    private func drawLabelScale(size: CGSize, scales: [GuidePlacement:DeterminedScale]) -> AnyView {
        let scale = scales[.xAxis]!.getLabelScale()!

        return ForEach(scale.majorSteps()) { t in
            Text("\(t.value ?? "" )")
                .allowsTightening(true)
                .frame(width: CGFloat(100), height: t.width.factor(by: size.width), alignment: .trailing)
                .rotationEffect(Angle(degrees: 270))
                
            .position(CGPoint(
                x: t.position.clamped(add: 0.5*t.width).factor(by: size.width),
                y: size.height+55))
        }
        .asAnyView
    }
    
    func drawAxes(chartSize: CGSize, forDeterminedScales scales: [GuidePlacement:DeterminedScale]) -> AnyView {
        // Ignore anything non-cartesian
        let cartesianScales = scales.filterWhereKey { $0.isCartesian() }
        return Group {
            drawAxisPath(size: chartSize, scales: cartesianScales )
            drawGuideScale(size: chartSize, scales: cartesianScales.filterWhereValue { $0.getGuideScale() != nil })
            drawLabelScale(size: chartSize, scales: cartesianScales.filterWhereValue { $0.getLabelScale() != nil })
        }
        .frame(width: chartSize.width,  height: chartSize.height)
        .asAnyView
    }
    
    func drawBox(chartSize: CGSize, at: UnitPoint, size: UnitSize, forScale scale: GuideScale) -> Path {
        Path { path in
         //   CGRect( origin: CGPoint( x:    ))
            path.addRect( CGRect(origin:  at.toCartesian(ofSize: chartSize),
                                 size: size.toCartesian(ofSize: chartSize)) )
        }
    }
    
    func drawLine(chartSize: CGSize, from: UnitPoint, to: UnitPoint, forScale: GuideScale) -> Path {
        return Path { path in
            path.move(to: from.toCartesian(ofSize: chartSize))
            path.addLine(to: to.toCartesian(ofSize: chartSize))
        }
    }
    
    func place<V>(chartSize: CGSize, view: V, at: UnitPoint) -> AnyView where V : View {
        return view.asAnyView
    }
    
}
