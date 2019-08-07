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

enum CartesianGuidePlacement {
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

typealias AxisLabel = String

struct Cartesian : CoordinateSystem {
    let axes: [CartesianGuidePlacement : (CartesianAxisType, AxisLabel)]
    static let GUIDE_LABEL_MAX_WIDTH : CGFloat = 40.0 // should really be related to font size
    static let TEXT_LABEL_MAX_WIDTH : CGFloat = 100.0 // should really be related to font size

    static let TEXT_LABEL_HEIGHT : CGFloat = +20.0  // should really be related to font size
    static let TEXT_LABEL_OFFSET : CGFloat = +8.0

    
    /// Figure out the scales given the axes requested, and the plots

    func determineGuideScales<D>(data: [D], plots: [ChartPlot<D>], labels: [String?]) ->
        PlacedDeterminedScales
    {
        var chartGuideDeterminedScale : PlacedDeterminedScales = [:]
        
        for cartesianScaleType in axes {
            let placement = cartesianScaleType.key.toGuidePlacement()
            
            switch cartesianScaleType.value {
                
                case let (.guide(guideScaleType), axisLabel):
                    var guideScale = guideScaleType.init()
                    for plot in plots {
                        guideScale.mergeData(data: data, mappings: plot.mappingForGuidePlacement(placement) )
                    }
                    chartGuideDeterminedScale[placement] = (.guideScale(guideScale), axisLabel)
                    
                case let (.labels(labelScaleType), axisLabel):
                    let labelScale = labelScaleType.init(labels: labels)
                    chartGuideDeterminedScale[placement] = (.labelScale( labelScale ), axisLabel)
                    
                default:
                    break
                }
        }
        
        return chartGuideDeterminedScale
    }
    

    private func drawAxisPath(size: CGSize, scales: PlacedDeterminedScales) -> AnyView {
        // for now
        let yscale = (scales[.yAxis]!).0.getGuideScale()!
        let xscale = (scales[.xAxis]!).0.getLabelScale()!

        let xaxisPosn = yscale.interceptPosn().inverse.factor(by: size.height)

        return Path { path in
            path.addRect(CGRect(x: 0, y: size.height, width: 2, height: -size.height))
            path.addRect(CGRect(x: 0, y: xaxisPosn, width: size.width, height: 2))
            
            for s in yscale.majorSteps() {
                let at = s.position.factor(by: size.height)
                path.addRect(CGRect(x: -2, y: size.height-at, width: 4, height: 2))
            }
            
            for s in xscale.majorSteps() {
                let at = s.position.factor(by:size.width)
                path.addRect(CGRect(x: at, y: xaxisPosn, width: 2, height: 4))
            }
        }
        .fill(Color.primary)
        .asAnyView
    }
    
    private func drawGuideScale(size: CGSize, scales: PlacedDeterminedScales) -> AnyView {
        let scale = (scales[.yAxis]!).0.getGuideScale()!
        let label = (scales[.yAxis]!).1

        return

            ZStack {
                ForEach(scale.majorSteps()) { t in
                    Text("\(scale.format(t.value))")
                        .allowsTightening(true)
                        .minimumScaleFactor(0.25)
                        .frame(width: Cartesian.GUIDE_LABEL_MAX_WIDTH, alignment: .trailing)
                        .position(CGPoint(x:-Cartesian.GUIDE_LABEL_MAX_WIDTH / 2.0 - Cartesian.TEXT_LABEL_OFFSET, y: t.position.inverse.factor(by:size.height) ) )
                }
                
                Text(label)
                    .italic()
                    .rotationEffect(Angle(degrees: 270))
                    .position(CGPoint(x:-(Cartesian.GUIDE_LABEL_MAX_WIDTH + Cartesian.TEXT_LABEL_HEIGHT), y: UnitValue(0.5).factor(by: size.height)))
                    .frame(width: CGFloat(size.height))
    
            }.asAnyView

    }
    
    /// Returns the font size which makes all elements in ts, including the largest, fit in the space of 'forMax' width
    // argh, needs special SwiftUI thinking here...
    
//    private func textWidthStandardizer<Content:View>(_ ts: [String], withFont font: UIFont, maxWidth: CGFloat, @ViewBuilder builder: @escaping (CGFloat) -> Content) -> Content {
//
//        let
//
//        // first find  the largest bounding box for a reasonable font size
//        guard let maxStringWidth = ts.map( { $0.widthOfString(usingFont: font) }).max() else { return builder(0.0) }
//
//        let ratio = maxWidth / maxStringWidth
//        if ratio >= 1.0 { return builder(font.si)}
//
//    }

    
    private func drawLabelScale(size: CGSize, scales: PlacedDeterminedScales) -> AnyView {
        let scale = (scales[.xAxis]!).0.getLabelScale()!
        let label = (scales[.xAxis]!).1

        return ZStack {
            ForEach(scale.majorSteps()) { t in
                Text("\(t.value ?? "" )")
                    .allowsTightening(true)
                    .frame(width: Cartesian.TEXT_LABEL_MAX_WIDTH, height: t.width.factor(by: size.width), alignment: .trailing)
                    .rotationEffect(Angle(degrees: 270))
                    .position(CGPoint(
                        x: t.position.clamped(add: 0.5*t.width).factor(by: size.width),
                        y: size.height + Cartesian.TEXT_LABEL_MAX_WIDTH / 2.0 + Cartesian.TEXT_LABEL_OFFSET))
                    
                Text(label)
                    .italic()
                    .position(CGPoint(x:UnitValue(0.5).factor(by: size.width),
                                      y: size.height + Cartesian.TEXT_LABEL_MAX_WIDTH + Cartesian.TEXT_LABEL_HEIGHT))
            }
        }.asAnyView
    }
    
    func drawAxes(chartSize: CGSize, forDeterminedScales scales: PlacedDeterminedScales) -> AnyView {
        // Ignore anything non-cartesian
        let cartesianScales = scales.filterWhereKey { $0.isCartesian() }
        return Group {
            drawAxisPath(size: chartSize, scales: cartesianScales )
            drawGuideScale(size: chartSize, scales: cartesianScales.filterWhereValue { $0.0.getGuideScale() != nil })
            drawLabelScale(size: chartSize, scales: cartesianScales.filterWhereValue { $0.0.getLabelScale() != nil })
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
