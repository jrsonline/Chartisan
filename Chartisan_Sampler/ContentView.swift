import SwiftUI

enum DType : CaseIterable  {
    case a, b
    var  isA : Bool { get {
        switch self { case .a: return true; default: return false }}
    }
    var  isB : Bool { get {
        switch self { case .b: return true; default: return false }}
    }
}

struct TestData :Identifiable{ let y1,y2,y3: Double; let type: DType; let label: String; let id: Int }
let testData : [TestData] = [ TestData(y1: 8, y2: 2,  y3: -4, type: .b, label:"Q1 2018", id:1),
                              TestData(y1: 2, y2: 6,  y3: 1, type: .a, label:"Q2 2018", id:2),
                              TestData(y1:  5, y2: 3, y3: 2, type: .b, label:"Q3 2018", id:3),
                              TestData(y1:  1, y2: 5, y3: -1, type: .a, label:"Q4 2018", id:4),
                              TestData(y1: 2, y2: 3, y3: 6, type: .a, label:"Q1 2019", id:5)]

struct ContentView: View {
    var body : some View {
        Chart(data:testData,
              labels: \.label,
              coords: Cartesian(axes:[.xAxis : .allLabels, .yAxis : .linearGuide ]),
              plots:[ BarChart(size: \.y1, annotation: "Capital", colour: .fixed(.yellow) ),
                      BarChart(size: \.y2, annotation: "People", colour: .flag(\.type.isA, ifTrue: .blue, ifFalse: .pink) ),
                      BarChart(size: \.y3, annotation: "Assets", colour: .posNeg(\.y3, pos: .green, neg:.red)),
 //                     LineChart(height: \.y3, guide: .y2ndAxis,  shape: .circle(/radius: \.capital), annotation: "Overage", colour: .custom({ $0.y3 > 0 ? .red : .green }))
                     ],
              blendMode: .fdodge(0.75)
            )
    }
}
// 'Measure'' maps data to double value (DV)
// AestheticScale maps DVs OR enums (?) to aesthetics : shape, colour, ...
// GuideScale maps DVs to UnitValue(-1...1) for coordinates
// Coordinate maps unit values to screen


/// stats must be separate, surely.  Why would a chart plotter be doing stats?
///
/// What about pie chart?   "coords:Radial()   ?   "    can we default this according to the plots...  if I try radial with a barchart what do i get... (a windchart?)
///    think about the options.. eg Cartesian(x:labels, y:labels) should give me  a table of cells I can colour in
///
/// Stacked - done, though -ve numbers not right DONE
/// Dodge -- again -ve numbers not right DONE
/// X axis labels ... not sure about font here
/// axis is temporary
/// flip Y and X axes
/// Better to have ColourScale as including the function"   '.stripes' instead of  'ColourScale.stripes' - NICE TO HAVE
/// Negative numbers  - done
/// broken scale, log scale
/// colour key
/// size of graph --> number of points to show
/// Try: log scale, polar graph


/// Should be specific about x and y.  Use a different graph if you want to do something different
/// Guides are used for reading... "position"-type scales draw axes, everything else draws a key


#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
