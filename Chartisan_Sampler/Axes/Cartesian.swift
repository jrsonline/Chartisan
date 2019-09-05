//
//  Cartesian.swift
//  Chartisan_Sampler
//
//  Created by RedPanda on 30-Jul-19.
//  Copyright © 2019 strictlyswift. All rights reserved.
//

import SwiftUI

enum CartesianAxisType {
    case labels(TextScale.Type)
    case guide(GuideScale.Type)
    case none
    
    func getGuideScaleType() -> GuideScale.Type? {
        switch self {
            case .guide(let g): return g
            default: return nil
        }
    }
    func getLabelScaleType() -> TextScale.Type? {
        switch self {
            case .labels(let l): return l
            default: return nil
        }
    }
}

extension CartesianAxisType {
    static let linearGuide = CartesianAxisType.guide(LinearScale.self )
    static let labelGuide = CartesianAxisType.labels(LabelScale.self )
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

    func determineChartSections(frame: CGRect, fullArea: CGSize, plotPercentage: CGFloat = 0.8, forScale: PlacedDeterminedScales<CartesianGuidePlacement>) -> ChartSections<CartesianGuidePlacement> {
        // centre the graph area in the frame
        let graphArea = fullArea.centredIn(frame)
        // we chop 20% off the bottom and left of the full area for the plot
        let plotArea = CGRect(x: graphArea.minX + graphArea.width*(1-plotPercentage),
                              y: graphArea.minY,
                              width: graphArea.width*plotPercentage,
                              height: graphArea.height*plotPercentage)
        
        let xAxisGuideArea = CGRect(x:plotArea.minX, y:plotArea.maxY, width:plotArea.width, height:graphArea.height*(1-plotPercentage))
        
        let yAxisGuideArea = CGRect(x:graphArea.minX, y:plotArea.minY, width:graphArea.width*(1-plotPercentage), height:plotArea.height)
        
        return ChartSections(plotArea: plotArea,
                             titleArea: CGRect.zero,
                             keyAreas: [],
                             guidePlacementAreas: [ .xAxis:xAxisGuideArea,
                                                    .yAxis:yAxisGuideArea]
        )
    }
    
    /// Figure out the scales given the axes requested, and the plots

    func determineGuideScales<D>(data: [D], plots: [ChartPlot<D, Self>], labels: [String?]) ->
        PlacedDeterminedScales<CartesianGuidePlacement>
    {
        var chartGuideDeterminedScale = PlacedDeterminedScales<CartesianGuidePlacement>()
        
        for cartesianScaleType in axes {
            let placement = cartesianScaleType.key
            
            switch cartesianScaleType.value {
                
                case let (.guide(guideScaleType), axisLabel):
                    var guideScale = guideScaleType.init()
                    for plot in plots {
                        guideScale.mergeData(data: data, mappings: plot.mappingForGuidePlacement(placement) )
                    }
                    chartGuideDeterminedScale.placedAt[placement] = (.guideScale(guideScale), axisLabel)

                    
                case let (.labels(labelScaleType), axisLabel):
                    let labelScale = labelScaleType.init(labels: labels)
                    chartGuideDeterminedScale.placedAt[placement] = (.labelScale( labelScale ), axisLabel)
                default:
                    break
                }
        }
        
        return chartGuideDeterminedScale
    }
    

    private func drawAxisPath(sections: ChartSections<CartesianGuidePlacement>, scales: PlacedDeterminedScales<CartesianGuidePlacement>) -> AnyView {
        // for now
        let yscale = (scales.placedAt[.yAxis]!).0.getMeasurableScale()
        let xscale = (scales.placedAt[.xAxis]!).0.getMeasurableScale()
        
        let chartSize = sections.plotArea.size
        let plotArea = sections.plotArea

        let xaxisPosn = yscale.interceptPosn().inverse.factor(by: chartSize.height)
        let yaxisPosn = xscale.interceptPosn().factor(by: chartSize.width)

        // plot area needs to move over. then the axis needs to move by that amount
        return Path { path in
            path.addRect(CGRect(x: yaxisPosn + plotArea.minX, y: plotArea.maxY, width: 2, height: -chartSize.height))
            path.addRect(CGRect(x: plotArea.minX, y: xaxisPosn + plotArea.minY, width: chartSize.width, height: 2))
            
            for s in yscale.majorSteps() {
                let at = s.position.factor(by: chartSize.height)
                path.addRect(CGRect(x: -2+yaxisPosn + plotArea.minX, y: plotArea.minY + at, width: 4, height: 2))
            }
            
            for s in xscale.majorSteps() {
                let at = s.position.factor(by:chartSize.width)
                path.addRect(CGRect(x: at + plotArea.minX, y: plotArea.minY + xaxisPosn, width: 2, height: 4))
            }
        }
        .fill(Color.primary)
        .asAnyView
    }
    
    private func drawGuideOnAxis(scale: MeasurableScale, placement: CartesianGuidePlacement, mainLabel: String, sections: ChartSections<CartesianGuidePlacement>, labelFont: UIFont) -> AnyView {
                    
        switch placement {
            
        case .xAxis:
            return putLabelsOnXAxis(scale: scale, sections: sections, mainLabel: mainLabel, labelFont: labelFont)
        case .yAxis:
            return putLabelsOnYAxis(scale: scale, sections: sections, mainLabel: mainLabel, labelFont: labelFont)
        case .x2ndAxis:
            fatalError("Currently unsupported, sorry!")
        case .y2ndAxis:
            fatalError("Currently unsupported, sorry!")
        }
    }

    
    func putLabelsOnXAxis(scale: MeasurableScale, sections: ChartSections<CartesianGuidePlacement>, mainLabel: String, labelFont: UIFont) -> AnyView {
        let stepWidth = scale.majorStepWidth().factor(by: sections.plotArea.width)
        let xAxisGuide = sections.guidePlacementAreas[.xAxis]!
        let maxAxisWidth = xAxisGuide.width
        let maxRotatedTextWidth = xAxisGuide.height - Cartesian.TEXT_LABEL_HEIGHT
                
        return
            RotatableLabelSet(labels: scale.majorSteps().map {$0.label},
                              containerSize: CGSize(width: stepWidth,
                                                    height: Cartesian.TEXT_LABEL_HEIGHT),
                              rotatedContainerSize: CGSize(width: Cartesian.TEXT_LABEL_HEIGHT,
                                                           height: maxRotatedTextWidth),
                              containerCentre: { idx in
                                let t = scale.majorSteps()[idx]
                                return CGPoint( x: t.position.factor(by: maxAxisWidth) + xAxisGuide.minX,
                                                y: xAxisGuide.minY) },
                              alignWithSteps: .xAlign(with: scale.centreTextBetweenSteps(), stepWidth: stepWidth),
                              alignmentPreference: RotatableLabelSet.RotatableAlignmentPreference(normal: .top, rotated: .top)
            ).with { coveringRect in
            
            RotatableLabel(label: mainLabel,
                           modifier: { $0.italic() },
                           containerSize: CGSize(width: coveringRect.width,
                                                 height: Cartesian.TEXT_LABEL_HEIGHT),
                           containerCentre: CGPoint( x: UnitValue(0.5).factor(by: maxAxisWidth) + xAxisGuide.minX,
                                                     y: coveringRect.maxY + Cartesian.TEXT_LABEL_HEIGHT*0.5),
                           alignWithSteps: .unaligned,
                           alignmentPreference: RotatableLabelSet.RotatableAlignmentPreference(normal: .centre, rotated: .centre))
            }
    }
    
    func putLabelsOnYAxis(scale: MeasurableScale, sections: ChartSections<CartesianGuidePlacement>, mainLabel: String, labelFont: UIFont) -> AnyView {
        
        let stepWidth = scale.majorStepWidth().factor(by: sections.plotArea.height)
        let yAxisGuide = sections.guidePlacementAreas[.yAxis]!
        let maxTextWidth = yAxisGuide.width
 //       let maxRotatedTextWidth = yAxisGuide.height
        let size = sections.plotArea.size
                
        let invert: (UnitValue) -> UnitValue = { v in
            if scale.reverseLabelsHint() { return v } else { return v.inverse }
        }
                
        return ZStack {
            RotatableLabelSet(labels: scale.majorSteps().map {$0.label},
                              containerSize: CGSize(width: maxTextWidth,
                                                    height: stepWidth),
                              containerCentre: { idx in
                                let t = scale.majorSteps()[idx]
                                return CGPoint( x: yAxisGuide.maxX,
                                                y: yAxisGuide.minY + invert(t.position).factor(by: size.height)) },
                              alignWithSteps:  .yAlign(with: scale.centreTextBetweenSteps(), stepWidth: stepWidth),
                              alignmentPreference: RotatableLabelSet.RotatableAlignmentPreference(normal: .right, rotated: .centre))
            
            RotatableLabel(label: mainLabel,
                           modifier: { $0.italic() },
                           containerSize: CGSize(width: maxTextWidth  /* Cartesian.YAXIS_MAINLABEL_MAX_WIDTH -maxAxisLabelWidth */,
                            height: Cartesian.TEXT_LABEL_HEIGHT),
                           rotatedContainerSize: CGSize(width: Cartesian.TEXT_LABEL_HEIGHT ,
                                                        height: size.height),
                           containerCentre: CGPoint( x: yAxisGuide.center.x,
                                                     y: yAxisGuide.minY),
                           rotatedContainerCentre: CGPoint( x: yAxisGuide.minX - Cartesian.TEXT_LABEL_HEIGHT,
                                                            y: yAxisGuide.center.y),
                           alignWithSteps: .unaligned,
                           alignmentPreference: RotatableLabelSet.RotatableAlignmentPreference(normal: .right, rotated: .centre))
        }.asAnyView
    }
    
    func drawAxes(chartSections: ChartSections<CartesianGuidePlacement>, forDeterminedScales scales: PlacedDeterminedScales<CartesianGuidePlacement>, style: ChartStyle) -> AnyView {
                
        // For a barchart, we need at least one (numeric) guide and exactly one label
        let guideScales = scales.placedAt.filterWhereValue { $0.0.getGuideScale() != nil }
        let labelScales = scales.placedAt.filterWhereValue { $0.0.getLabelScale() != nil }
        
        guard guideScales.count >= 1 && labelScales.count == 1 else { fatalError("Barchart needs at least one (numeric) guide and exactly one label scale") }
        
        guard let xAxis = scales.placedAt[.xAxis] else { fatalError("Must provide an xAxis")}
        guard let yAxis = scales.placedAt[.yAxis] else { fatalError("Must provide a yAxis")}
        
        return ZStack {
            drawAxisPath(sections: chartSections, scales: scales )
            drawGuideOnAxis(scale:xAxis.0.getMeasurableScale(), placement: .xAxis, mainLabel: xAxis.1, sections: chartSections, labelFont: style.labelFont)
            drawGuideOnAxis(scale:yAxis.0.getMeasurableScale(), placement: .yAxis, mainLabel: yAxis.1, sections: chartSections, labelFont: style.labelFont)
        }
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

