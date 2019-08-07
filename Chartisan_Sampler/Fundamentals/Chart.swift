//
//  Chart.swift
//  Chartisan_Sampler
//
//  Created by RedPanda on 28-Jul-19.
//  Copyright © 2019 strictlyswift. All rights reserved.
//

import SwiftUI


struct Chart<D> : View
{
    let size: CGSize
    let data: [D]
    let labels: (D) -> String?
    let coords: CoordinateSystem
    let plots: [ChartPlot<D>]
    let annotations: [AnyView] = []
    let blendMode: ChartLayerBlendMode
    
    init(
        size: CGSize = CGSize(width:200, height:200),
        data: [D],
        labels: @escaping (D) -> String? = { d in "\(d)" },
        coords: CoordinateSystem = Cartesian(axes:[.xAxis : (.allLabels,""), .yAxis : (.linearGuide,"") ]),
        plots: [ChartPlot<D>],
  //      annotations: [AnyView] = [],
        blendMode: ChartLayerBlendMode
    ) {
        self.size = size
        self.data = data
        self.labels = labels
        self.coords = coords
        self.plots = plots
 //       self.annotations = annotations
        self.blendMode = blendMode
    }
    
    init(
        size: CGSize = CGSize(width:200, height:200),
        data: [D],
        labels: KeyPath<D,String>,
        coords: CoordinateSystem,
        plots: [ChartPlot<D>],
  //      annotations: [AnyView] = [],
        blendMode: ChartLayerBlendMode
    ) {
        self.size = size
        self.data = data
        self.labels = { d in d == nil ? "" : d![keyPath:labels] }
        self.coords = coords
        self.plots = plots
  //      self.annotations = annotations
        self.blendMode = blendMode
    }
    
    /// Determine the scales to use given the guides requested by each chart, and the axes chosen
    func determineScales<Content:View>(forPlots plots: [ChartPlot<D>], @ViewBuilder builder: @escaping (PlacedDeterminedScales) -> Content) -> Content {
        return builder(self.doDetermineScales(forPlots: plots))
    }
    
    func doDetermineScales(forPlots plots: [ChartPlot<D>]) -> PlacedDeterminedScales {
        // the coordinate system determines the scales, given the data and the plot guides
        return self.coords.determineGuideScales(data:self.data, plots: plots, labels: data.map( self.labels ))
    }
    
    /// Merge and reprocess similar  plots in order to blend several plots into potentially different plots
    func doPlotMerge() -> [ChartPlot<D>] {
        var blendedPlots : [ChartPlot<D>] = []
        
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
    
    func plotMerge<Content:View>(@ViewBuilder builder: @escaping ([ChartPlot<D>]) -> Content) -> Content {
        return builder(self.doPlotMerge())
    }
    
    func renderPlot(plot: ChartPlot<D>, scales: PlacedDeterminedScales) -> AnyView {
        return plot.render(withCoords: self.coords, ofSize: self.size, for: self.data, scales: scales)
    }
 
    var body: some View {
        self.plotMerge { mergedPlots in
            self.determineScales(forPlots: mergedPlots) { scales in
                ZStack {
                    ForEach(mergedPlots) { plot in
                        self.renderPlot(plot: plot, scales: scales)
                    }
                    self.coords.drawAxes(chartSize: self.size, forDeterminedScales: scales)
                }
            }
        }
    }
}

