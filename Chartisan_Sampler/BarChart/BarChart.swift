//
//  BarChart.swift
//  Chartisan_Sampler
//
//  Created by RedPanda on 28-Jul-19.
//  Copyright © 2019 strictlyswift. All rights reserved.
//

import SwiftUI

struct BarConfiguration {
    let barWidth = 0.9
    let barGap : Double = 0
}

/// Force Optional to be identifiable when it wraps an int-identifiable value
extension Optional : Identifiable
where Wrapped:Identifiable, Wrapped.ID == Int, Wrapped.IdentifiedValue == Wrapped
{
    public var id : Int { get {
        switch self {
        case .none:
            return Int.min
        case .some(let v):
            return v.id
        }
    }}
}

class BarChart<D, Coords: CoordinateSystem> : ChartPlot<D, Coords>
{
    let slices : [BarSlice<D, Coords.AllowedGuidePlacements>]
    let barConfiguration : BarConfiguration

    init( slices: [BarSlice<D, Coords.AllowedGuidePlacements>],
          barConfiguration: BarConfiguration) {
        self.slices = slices
        self.barConfiguration = barConfiguration
        super.init()
        
        self.mergeKey = "BarChart"
    }
    
    convenience init(
            size:@escaping (D) -> (Double?),
            onto guide: Coords.AllowedGuidePlacements,// = .yAxis,
            annotation: String = "",
            min:@escaping (D) -> Double = { _ in 0},  // change to 'min'
            colour: ChartColour<D> = .stripe(.green,.blue),
            width:@escaping (D) -> Double = { _ in 1.0},
            dodge:@escaping (D) -> Double = { _ in 0.0},
            barConfiguration: BarConfiguration = BarConfiguration() ) {
        self.init(slices :[BarSlice(
            label: annotation,
            height: size,
            guide: guide,
            bottom: min,
            width: width,
            dodge: dodge,
            colour: colour
            )],
                  barConfiguration: barConfiguration
        )
    }

    
    convenience init( sizeOrNil:KeyPath<D,Double?>,
                     onto guide: Coords.AllowedGuidePlacements,// = .yAxis,
                     annotation: String = "",
                     min:(KeyPath<D,Double>)? = nil,
                     colour:ChartColour<D> = .stripe(.green,.blue),
                     width:(KeyPath<D,Double>)? = nil,
                     dodge:@escaping (D) -> Double = { _ in 0.0},
                     barConfiguration: BarConfiguration = BarConfiguration()) {
        
        self.init(slices: [BarSlice(label: annotation,
                                    height:{ d in d[keyPath: sizeOrNil] },
                                    guide: guide,
                                    bottom: min == nil ? { _ in 0} : { d in d[keyPath: min!] },
                                    width: width == nil ? { _ in 1.0} : { d in d[keyPath: width!] },
                                    dodge: dodge,
                                    colour: colour

            )],
                  barConfiguration: barConfiguration
        )
    }
        
    convenience init( size:KeyPath<D,Double>,
                     onto guide: Coords.AllowedGuidePlacements,// = .yAxis,
                     annotation: String = "",
                     min:KeyPath<D,Double>? = nil,
                     colour:ChartColour<D> = .stripe(.green,.blue),
                     width:KeyPath<D,Double>? = nil,
                     dodge:@escaping (D) -> Double = { _ in 0.0},
                     barConfiguration: BarConfiguration = BarConfiguration()) {
        
        self.init(slices: [BarSlice(label: annotation,
                                    height:{ d in d[keyPath: size] },
                                    guide: guide,
                                    bottom: min == nil ? { _ in 0} : { d in d[keyPath: min!] },
                                    width: width == nil ? { _ in 1.0} : { d in d[keyPath: width!] },
                                    dodge: dodge,
                                    colour: colour

            )],
                  barConfiguration: barConfiguration
        )

    }
    

    func bar(coords: Coords, slice islice: IndexedItem<BarSlice<D, Coords.AllowedGuidePlacements>>, withItem iitem: IndexedItem<D>, ofNumber n: Int, fromSize plotSize: CGSize, scalingBy gscale: GuideScale?) -> Path {
        guard let scale = gscale else { fatalError("No guide scale provided for bar chart")}
        
        let slice = islice.dt
        let sliceIdx = islice.id
        let item = iitem.dt
        let itemIdx = iitem.id
        
        // if the data item is nil, we don't draw anything
        guard let top = slice.top(item) else {
            return coords.drawBox(chartSize: plotSize,
                                  at: UnitPoint.zero,
                                  size: UnitSize.zero,
                                  forScale: scale,
                                  on: slice.guide)
        }
        
        let floating = scale[slice.bottom(item)]

        let barHeight = UnitValue(floating - scale[top])

        let barSize = UnitSize( width: UnitValue( (slice.width(item) / n.asDouble) * self.barConfiguration.barWidth),
                             height: barHeight)
        
        let barSectionStart = itemIdx.asDouble/n.asDouble

        let origin = UnitPoint( UnitValue( ( slice.dodge(item) * slices.count.asDouble) * barSize.size.width.asDouble + barSectionStart ),
                                floating)
        return coords.drawBox(chartSize: plotSize,
                              at: origin,
                              size: barSize,
                              forScale: scale,
                              on: slice.guide)
    }
    
    override func render(withCoords coords: Coords, ofSize size: CGSize, for data:[D], scales: PlacedDeterminedScales<Coords.AllowedGuidePlacements>, style: ChartStyle) -> AnyView {
        guard !data.isEmpty else { return EmptyView().asAnyView }
        
        let indexableSlices = IndexedItem.box(slices)
        let indexableData = IndexedItem.box(data)

        return ZStack {
            ForEach(indexableSlices) { slice in
                ForEach(indexableData) { d in
                    self.bar(coords: coords,
                             slice: slice,
                             withItem: d,
                             ofNumber: data.count,
                             fromSize: size,
                             scalingBy: scales[slice.dt.guide]?.0.getGuideScale()
                    ).fill(slice.dt.colour.colourFor(idx: d.id, datum: d.dt))
                }
            }
        }.frame(width: size.width,  height: size.height)
            .asAnyView
    }
    
    override func mappingForGuidePlacement(_ placement: Coords.AllowedGuidePlacements) -> [(D) -> Double?] {
        // find slices with indicated placement.
        return self.slices.filter ({ $0.guide == placement }).map( {$0.top })
    }

    override func merge(plots: [ChartPlot<D, Coords>], blendMode: ChartLayerBlendMode) -> [ChartPlot<D, Coords>] {
        guard (plots.allSatisfy { $0.mergeKey == self.mergeKey }) else {fatalError("Trying to merge charts with different merge keys")}
        var allSlices = Array<BarSlice<D, Coords.AllowedGuidePlacements>>()
        for plot in plots {
            let barChart = plot as! BarChart
            allSlices += barChart.slices.map { $0 }
        }
        
        let mergedSlices = BarSlice.blend(blendMode: blendMode, slices: allSlices)
        
        let mergedBar = BarChart(slices: mergedSlices, barConfiguration: self.barConfiguration)
        return [mergedBar]
    }
}

