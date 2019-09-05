//
//  Chart.swift
//  Chartisan_Sampler
//
//  Created by RedPanda on 28-Jul-19.
//  Copyright © 2019 strictlyswift. All rights reserved.
//

import SwiftUI


public struct Chart<D, Coords: CoordinateSystem> : View
{
    let size: CGSize
    let data: [D]
    let labels: (D) -> String?
    let coords: Coords
    let plots: [ChartPlot<D, Coords>]
    let annotations: [AnyView] = []
    let blendMode: ChartBlendMode
    let style: ChartStyle
    
    @Environment(\.viewAnnotation) private var va


    public init(
        size: CGSize = CGSize(width:200, height:200),
        data: [D],
        labels: @escaping (D) -> String? = { d in "\(d)" },
        coords: Coords, //= Cartesian(axes:[.xAxis : (.labelGuide,""), .yAxis : (.linearGuide,"") ]),
        plots: [ChartPlot<D, Coords>],
  //      annotations: [AnyView] = [],
        blendMode: ChartBlendMode,
        style: ChartStyle = ChartStyle()
        
    ) {
        self.size = size
        self.data = data
        self.labels = labels
        self.coords = coords
        self.plots = plots
 //       self.annotations = annotations
        self.blendMode = blendMode
        self.style = style
    }
    
    public init(
        size: CGSize = CGSize(width:200, height:200),
        data: [D],
        labels: KeyPath<D,String>,
        coords: Coords,
        plots: [ChartPlot<D, Coords>],
  //      annotations: [AnyView] = [],
        blendMode: ChartBlendMode,
        style: ChartStyle = ChartStyle()
    ) {
        self.size = size
        self.data = data
        self.labels = { d in d == nil ? "" : d![keyPath:labels] }
        self.coords = coords
        self.plots = plots
  //      self.annotations = annotations
        self.blendMode = blendMode
        self.style = style
    }
    
    /// Determine the scales to use given the guides requested by each chart, and the axes chosen
    func determineScales<Content:View>(forPlots plots: [ChartPlot<D, Coords>], @ViewBuilder builder: @escaping (PlacedDeterminedScales<Coords.AllowedGuidePlacements>) -> Content) -> Content {
        return builder(self.doDetermineScales(forPlots: plots))
    }
    
    func doDetermineScales(forPlots plots: [ChartPlot<D, Coords>]) -> PlacedDeterminedScales<Coords.AllowedGuidePlacements> {
        // the coordinate system determines the scales, given the data and the plot guides
        return self.coords.determineGuideScales(data:self.data, plots: plots, labels: data.map( self.labels ))
    }
    
    /// Determine the size and position of the chart within the outer frame
    func determineChartSections<Content:View>(geometry: GeometryProxy, requestedSize: CGSize, forScale scale: PlacedDeterminedScales<Coords.AllowedGuidePlacements>, @ViewBuilder builder: @escaping (ChartSections<Coords.AllowedGuidePlacements>) -> Content) -> Content {
        return builder(self.doDetermineSections(frame: geometry.frame(in: .local), fullArea: requestedSize, forScale: scale))
    }
    
    func doDetermineSections(frame: CGRect, fullArea: CGSize, forScale scale:PlacedDeterminedScales<Coords.AllowedGuidePlacements>) -> ChartSections<Coords.AllowedGuidePlacements> {
        self.coords.determineChartSections(frame: frame, fullArea: fullArea, plotPercentage: 0.7, forScale: scale)
    }
    
    
    /// Merge and reprocess similar  plots in order to blend several plots into potentially different plots
    func doPlotMerge() -> [ChartPlot<D, Coords>] {
        var blendedPlots : [ChartPlot<D, Coords>] = []
        
        // Merge all similar charts into a single  chart
        let pairedWithMergeKey = zip(self.plots, self.plots.map { $0.mergeKey ?? "None" })
        let groupedMerged = Dictionary(grouping: pairedWithMergeKey, by: {$0.1})
        
        for merge in groupedMerged {
            if merge.0 != "None" {
                let plots = merge.1.map { $0.0 }
                let mergedPlots = plots[0].merge(plots: plots, blendMode: self.blendMode)
                blendedPlots.append(contentsOf:mergedPlots)
            }
        }
        return blendedPlots
    }
    
    func plotMerge<Content:View>(@ViewBuilder builder: @escaping ([ChartPlot<D, Coords>]) -> Content) -> Content {
        return builder(self.doPlotMerge())
    }
    
    func renderPlot(sections: ChartSections<Coords.AllowedGuidePlacements>, plot: ChartPlot<D, Coords>, scales: PlacedDeterminedScales<Coords.AllowedGuidePlacements>) -> AnyView  {

        va?["chartCoordinates"] = self.coords
        
        return plot.render(withCoords: self.coords, inArea: sections, for: self.data, scales: scales, style: self.style)
        .asAnyView
    }
 
    public var body: some View {
        GeometryReader { geometry in
                self.plotMerge { mergedPlots in
                    self.determineScales(forPlots: mergedPlots) { scales in
                        self.determineChartSections(geometry: geometry, requestedSize: self.size, forScale: scales) { sections in
                            ZStack {
                                ForEach(mergedPlots) { plot in
                                    self.renderPlot(sections: sections, plot: plot, scales: scales)
                                }
                                self.coords.drawAxes(chartSections: sections, forDeterminedScales: scales, style: self.style)
                            }.position(geometry.frame(in: .local).center)
                    }
                }
            }
        }
        .frame(width: size.width, height: size.height, alignment: Alignment(horizontal: .center, vertical: .center))

    }
}

