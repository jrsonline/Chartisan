//
//  ChartLayer.swift
//  Chartisan_Sampler
//
//  Created by RedPanda on 28-Jul-19.
//  Copyright © 2019 strictlyswift. All rights reserved.
//

import SwiftUI

enum ChartLayerBlendMode {
    case none
    case dodge
    case fdodge(Double)
    case stack
    case jitter(Double)
}

/*
struct ChartLayer<D:Identifiable> {
    // charts on the same layer share scales
    let plots: [ChartPlot<D>] // geom
    let scales: Scales
    let blendMode: ChartLayerBlendMode
    
    init(plots: [ChartPlot<D>],
         scales: Scales = Scales(),
         blendMode: ChartLayerBlendMode = .stack) {
        self.plots = plots
        self.blendMode = blendMode
        self.scales = scales
    }
    
    func load(_ data: [D], plots: [ChartPlot<D>], with scales: Scales) -> ComputedScales {
        let computedScales = ComputedScales()
        var double1data : [Double] = []
     //   var double2data : [Double] = []
        var colourdata : [Double] = []
        var labeldata : [String] = []
        var sliceCount = 0
        
        for p in plots {
            double1data.append(contentsOf: p.getDouble1MappedData(for: data, blendMode: self.blendMode) )
            colourdata.append(contentsOf: p.getColourMappedData(for: data, blendMode: self.blendMode) )
            labeldata.append(contentsOf: p.getLabelMappedData(for: data, blendMode: self.blendMode))
            sliceCount += p.getSliceCount()
        }
        if scales.yDoubleScale != nil {
            computedScales.yDoubleComputedScale = self.scales.yDoubleScale!(double1data)
        }
        if scales.colourScale != nil {
            computedScales.colourComputedScale = self.scales.colourScale!(colourdata, sliceCount)
        }
        if scales.xLabelScale != nil {
            computedScales.xLabelComputedScale = self.scales.xLabelScale!(labeldata)
        }
        return computedScales
    }
    
    func blendPlots(for data:[D]) -> ([ChartPlot<D>], [D], ComputedScales) {
        // blending plots can reprocess chart plots in order to blend several plots into different plots
        var blendedPlots : [ChartPlot<D>] = []
        
        // Merge all similar charts into a single  chart
        let pairedWithMergeKey = zip(self.plots, self.plots.map { $0.mergeKey ?? "None" })
        let groupedMerged = Dictionary(grouping: pairedWithMergeKey, by: {$0.1})
        //let barCharts = self.plots.filter { $0 is ChartMergeable && ($0 as! ChartMergeable).mergeKey == "BarChart" }
        
        for merge in groupedMerged {
            if merge.0 != "None" {
                let plots = merge.1.map { $0.0 }
                let mergedPlots = plots[0].merge(plots: plots, blendMode: self.blendMode)
                blendedPlots.append(contentsOf:mergedPlots)
            }
        }
        
        let computedScales = self.load(data, plots: blendedPlots, with: scales)

        return (blendedPlots, data, computedScales)
    }
        
    func render(ofSize size: CGSize, for data:[D]) -> some View {
        let (blendedPlots, data, blendedScales) = self.blendPlots(for: data)

        return ZStack {
            ForEach(_IndexedItem.box(blendedPlots)) { blendedPlot in
                blendedPlot.dt.render(ofSize: size, for: data, scales: blendedScales)
            }
        }
    }
    
    /// temporary
    func getScale(for data:[D]) -> DoubleScale {
        let (_, _, blendedScales) = self.blendPlots(for: data)
        let yDoubleComputedScale = blendedScales.yDoubleComputedScale
        guard yDoubleComputedScale != nil else { fatalError("yDoubleComputedScale not set!") }
        return yDoubleComputedScale!
    }
    
    /// more temporary
    func getLabelScale(for data:[D]) -> LabelScale {
        let (_, _, blendedScales) = self.blendPlots(for: data)
        let xLabelComputedScale = blendedScales.xLabelComputedScale
        guard xLabelComputedScale != nil else { fatalError("xLabelComputedScale not set!") }
        return xLabelComputedScale!
    }

//    let statistic: Statistic<D,E>
//    let position: PositionAdjustment
//    let aes: [AestheticMapping<E>]
}
*/
