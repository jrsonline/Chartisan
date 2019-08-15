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
    static let labelGuide = CartesianAxisType.labels(AllLabelScale.self )
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
    static let TEXT_LABEL_MAX_WIDTH : CGFloat = 80.0 // should really be related to font size

    static let TEXT_LABEL_HEIGHT : CGFloat = +20.0  // should really be related to font size
    static let TEXT_LABEL_OFFSET : CGFloat = +8.0
    
    static let YAXIS_MAINLABEL_MAX_WIDTH : CGFloat = 50.0  // after this, we show at top. Again, should be font size related

    
    /// Figure out the scales given the axes requested, and the plots

    func determineGuideScales<D>(data: [D], plots: [ChartPlot<D, Self>], labels: [String?]) ->
        PlacedDeterminedScales<CartesianGuidePlacement>
    {
        var chartGuideDeterminedScale : PlacedDeterminedScales<CartesianGuidePlacement> = [:]
        
        for cartesianScaleType in axes {
            let placement = cartesianScaleType.key
            
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
    

    private func drawAxisPath(size: CGSize, scales: PlacedDeterminedScales<CartesianGuidePlacement>) -> AnyView {
        // for now
        let yscale = (scales[.yAxis]!).0.getMeasurableScale()
        let xscale = (scales[.xAxis]!).0.getMeasurableScale()

        let xaxisPosn = yscale.interceptPosn().inverse.factor(by: size.height)
        let yaxisPosn = xscale.interceptPosn().factor(by: size.width)

        return Path { path in
            path.addRect(CGRect(x: yaxisPosn, y: size.height, width: 2, height: -size.height))
            path.addRect(CGRect(x: 0, y: xaxisPosn, width: size.width, height: 2))
            
            for s in yscale.majorSteps() {
                let at = s.position.factor(by: size.height)
                path.addRect(CGRect(x: -2+yaxisPosn, y: size.height-at, width: 4, height: 2))
            }
            
            for s in xscale.majorSteps() {
                let at = s.position.factor(by:size.width)
                path.addRect(CGRect(x: at, y: xaxisPosn, width: 2, height: 4))
            }
        }
        .fill(Color.primary)
        .asAnyView
    }
    
    private func drawGuideScale(size: CGSize, scales: PlacedDeterminedScales<CartesianGuidePlacement>, labelFont: UIFont) -> AnyView {
        assert(scales.count == 1, "Currently must have just one guide scale for a bar graph, sorry!")
        let guideAxis = Array(scales.keys)[0]

        let scale = (scales[guideAxis]!).0.getGuideScale()!
        let mainLabel = (scales[guideAxis]!).1
        
        guard let firstStep = scale.majorSteps().first else {return EmptyView().asAnyView}
        

        switch guideAxis {
            
        case .xAxis:
            let maxTextWidth = firstStep.width.factor(by: size.width)
            return putLabelsOnXAxis(scale: scale, centredLabels: false, maxTextWidth: maxTextWidth, maxRotatedTextWidth: Cartesian.TEXT_LABEL_MAX_WIDTH, size: size, mainLabel: mainLabel, labelFont: labelFont)
        case .yAxis:
            let maxTextWidth = firstStep.width.factor(by: size.height)
            return putLabelsOnYAxis(scale: scale, centredLabels: false, maxTextWidth: Cartesian.TEXT_LABEL_MAX_WIDTH, maxRotatedTextWidth: maxTextWidth, size: size, reverse: false, mainLabel: mainLabel, labelFont: labelFont)
        case .x2ndAxis:
            fatalError("Currently unsuppported, sorry!")
        case .y2ndAxis:
            fatalError("Currently unsuppported, sorry!")
        }
    }
    
    /// Returns the font size which makes all elements in ts, including the largest, fit in the space of 'forMax' width
    // argh, needs special SwiftUI thinking here...
    
    private func textWidthStandardizer<Content:View>(_ ts: [String], withFont font: UIFont, maxWidth: CGFloat, maxRotatedWidth: CGFloat, @ViewBuilder builder: @escaping (CGFloat,Bool) -> Content) -> Content {

        // first find  the largest bounding box for a reasonable font size
        guard let maxStringWidth = ts.map( { $0.widthOfString(usingFont: font) }).max() else { return builder(0.0, false) }

        let ratio = maxWidth / maxStringWidth
        let rotatedRatio = maxRotatedWidth / maxStringWidth
        switch (ratio, rotatedRatio) {
            case (0..<0.7, 1.0...) : return builder(floor(font.pointSize), true)
            case (0..<0.7, 0.7..<1.0) : return builder(floor(font.pointSize) * rotatedRatio, true)
            case (0.7..<1.0,_): return builder(floor(font.pointSize * ratio), false)
            default : return builder(font.pointSize,false)
        }
    }

    
    private func drawLabelScale(size: CGSize, scales: PlacedDeterminedScales<CartesianGuidePlacement>, labelFont: UIFont) -> AnyView {
        assert(scales.count == 1)

        let labelAxis = Array(scales.keys)[0]
        let scale = (scales[labelAxis]!).0.getLabelScale()!
        let mainLabel = (scales[labelAxis]!).1
        
        guard let firstStep = scale.majorSteps().first else {return EmptyView().asAnyView}
        
        switch labelAxis {
            
        case .xAxis:
            let maxTextWidth = firstStep.width.factor(by: size.width)
            return putLabelsOnXAxis(scale: scale, centredLabels: true, maxTextWidth: maxTextWidth, maxRotatedTextWidth: Cartesian.TEXT_LABEL_MAX_WIDTH, size: size, mainLabel: mainLabel, labelFont: labelFont)
        case .yAxis:
            let maxTextWidth = firstStep.width.factor(by: size.height)
            return putLabelsOnYAxis(scale: scale, centredLabels: true, maxTextWidth: Cartesian.TEXT_LABEL_MAX_WIDTH, maxRotatedTextWidth: maxTextWidth, size: size, reverse: true, mainLabel: mainLabel, labelFont: labelFont)
        case .x2ndAxis:
            fatalError("Currently unsuppported, sorry!")
        case .y2ndAxis:
            fatalError("Currently unsuppported, sorry!")
        }
    }
    
    func putLabelsOnXAxis(scale: MeasurableScale, centredLabels: Bool, maxTextWidth: CGFloat, maxRotatedTextWidth: CGFloat, size: CGSize, mainLabel: String, labelFont: UIFont) -> AnyView {
        let labelOffset = centredLabels ? 0.5 : 0.0

        return self.textWidthStandardizer(scale.majorSteps().map{$0.label}, withFont: labelFont, maxWidth: maxTextWidth, maxRotatedWidth: maxRotatedTextWidth) { fontSize, rotated in
            ZStack {
                ForEach(scale.majorSteps() ) { t in
                    Text("\(t.label)")
                        .allowsTightening(true)
                        .font(labelFont.toSwiftUI(size: fontSize))
                        .frame(
                            width: rotated ? maxRotatedTextWidth : maxTextWidth, alignment: rotated ? .trailing: .center)
                        .rotationEffect(Angle(degrees: rotated ? 270.0 : 0.0))
                        .position(
                            x: t.position.clamped(add: labelOffset*t.width).factor(by: size.width),
                            y: size.height + (rotated ? maxRotatedTextWidth / 2.0 : Cartesian.TEXT_LABEL_OFFSET) +  Cartesian.TEXT_LABEL_OFFSET)
                }
                
                Text(mainLabel)
                    .italic()
                    .allowsTightening(true)
                    .frame(width: size.width, alignment: .center)
                    .position(
                        x: UnitValue(0.5).factor(by: size.width),
                        y: size.height + (rotated ? maxRotatedTextWidth : Cartesian.TEXT_LABEL_HEIGHT) + Cartesian.TEXT_LABEL_HEIGHT)
            }
        }.asAnyView
    }
    
    func putLabelsOnYAxis(scale: MeasurableScale, centredLabels: Bool, maxTextWidth: CGFloat, maxRotatedTextWidth: CGFloat, size: CGSize, reverse: Bool, mainLabel: String, labelFont: UIFont) -> AnyView {
        let labelOffset = centredLabels ? 0.5 : 0.0
        let topMainLabel = maxTextWidth > Cartesian.YAXIS_MAINLABEL_MAX_WIDTH

        let mainLabelView : AnyView
        if topMainLabel {
            mainLabelView = Text(mainLabel)
                .italic()
                .allowsTightening(true)
                .frame(width: maxTextWidth, alignment: .trailing)
                .position(
                    x: -(maxTextWidth / 2.0 + Cartesian.TEXT_LABEL_OFFSET),
                    y: -Cartesian.TEXT_LABEL_HEIGHT)
                .asAnyView
        } else {
            mainLabelView = Text(mainLabel)
                .italic()
                .allowsTightening(true)
                .frame(width: size.height, alignment: .center)
                .rotationEffect(Angle(degrees:270))
                .position(
                    x: -maxTextWidth - Cartesian.TEXT_LABEL_HEIGHT/2.0,
                    y: UnitValue(0.5).factor(by: size.height))
                .asAnyView
        }
        
        let invert: (UnitValue) -> UnitValue = { v in
            if reverse { return v } else { return v.inverse }
        }
                
        return ZStack {
            self.textWidthStandardizer(scale.majorSteps().map{$0.label}, withFont: labelFont, maxWidth: maxTextWidth, maxRotatedWidth: maxRotatedTextWidth) { fontSize, rotated in
                ForEach(scale.majorSteps() ) { t in
                    Text("\(t.label)")
                        .allowsTightening(true)
                        .font(labelFont.toSwiftUI(size: fontSize))
                        .frame(
                            width: rotated ? maxRotatedTextWidth : maxTextWidth,
                            height: t.width.factor(by: size.height), alignment: .trailing)
                        .rotationEffect(Angle(degrees:rotated ? 270.0 : 0.0))
                        .position(
                            x: -(maxTextWidth / 2.0 + Cartesian.TEXT_LABEL_OFFSET),
                            y: invert( t.position.clamped(add: labelOffset*t.width)).factor(by: size.height))
                }
            }
            mainLabelView
        }.asAnyView
    }
    
    func drawAxes(chartSize: CGSize, forDeterminedScales scales: PlacedDeterminedScales<CartesianGuidePlacement>, style: ChartStyle) -> AnyView {
        // For a barchart, we need at least one (numeric) guide and exactly one label
        let guideScales = scales.filterWhereValue { $0.0.getGuideScale() != nil }
        let labelScales = scales.filterWhereValue { $0.0.getLabelScale() != nil }
        
        guard guideScales.count >= 1 && labelScales.count == 1 else { fatalError("Barchart needs at least one (numeric) guide and exactly one label scale") }
                
        return Group {
            drawAxisPath(size: chartSize, scales: scales )
            drawGuideScale(size: chartSize, scales: guideScales, labelFont: style.labelFont)
            drawLabelScale(size: chartSize, scales: labelScales, labelFont: style.labelFont)
        }
        .frame(width: chartSize.width,  height: chartSize.height)
        .asAnyView
    }
    
    func drawBox(chartSize: CGSize, at: UnitPoint, size: UnitSize, forScale scale: GuideScale, on guide: CartesianGuidePlacement) -> Path {
        
        
        let rectOrigin: UnitPoint
        let rectSize: UnitSize
        switch guide {
            case .yAxis:
                rectOrigin = at
                rectSize = size
            case .xAxis:
                rectOrigin = at.rotateRight90().forcePositiveQuadrant().invert()
                rectSize = size.rotateRight90().widthMult(-1.0)

            case .x2ndAxis:
                fatalError("Not implemented yet, sorry!")
            case .y2ndAxis:
                fatalError("Not implemented yet, sorry!")
        }

        return Path { path in
            path.addRect( CGRect(origin: rectOrigin.toCartesian(ofSize: chartSize),
                                 size: rectSize.toCartesian(ofSize: chartSize)) )
        }
    }
    
    func drawLine(chartSize: CGSize, from: UnitPoint, to: UnitPoint, forScale: GuideScale, on: CartesianGuidePlacement) -> Path {
        return Path { path in
            path.move(to: from.toCartesian(ofSize: chartSize))
            path.addLine(to: to.toCartesian(ofSize: chartSize))
        }
    }
    
    func place<V>(chartSize: CGSize, view: V, at: UnitPoint) -> AnyView where V : View {
        return view.asAnyView
    }
    
}

