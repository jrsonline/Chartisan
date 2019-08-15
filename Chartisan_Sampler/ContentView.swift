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

struct TestData { let y1,y2,y3: Double?; let type: DType; let label: String; let id: Int }
let testData : [TestData] = [ TestData(y1: nil, y2: 2,  y3: 4, type: .b, label:"Q1", id:1),
                              TestData(y1: 2, y2: 6,  y3: 1, type: .a, label:"Q2", id:2),
                              TestData(y1:  5, y2: 3, y3: 2, type: .b, label:"Q3", id:3),
                              TestData(y1:  1, y2: 5, y3: nil, type: .a, label:"Q4", id:4),
                              TestData(y1: 2, y2: 3, y3: 6, type: .a, label:"Q1", id:5)]

struct ContentView: View {
    
    var body : some View {
        Chart(data:testData,
              labels: \.label,
              coords: Cartesian(axes:[.yAxis : (.labelGuide,"Quarter"),
                                      .xAxis : (.linearGuide,"Dollars, million")  ]),
              plots:[ BarChart(sizeOrNil: \.y1, onto: .xAxis, annotation: "Capital", colour: .fixed(.yellow) ),
                      BarChart(sizeOrNil: \.y2, onto: .xAxis,annotation: "People", colour: .flag(\.type.isA, ifTrue: .blue, ifFalse: .pink) ),
                      BarChart(sizeOrNil: \.y3, onto: .xAxis, annotation: "Assets", colour: .posNegNil(\.y3, pos: .green, neg:.red)),
 //                     LineChart(height: \.y3, guide: .y2ndAxis,  shape: .circle(/radius: \.capital), annotation: "Overage", colour: .custom({ $0.y3 > 0 ? .red : .green }))
                     ],
              blendMode:  .stack // .fdodge(0.75),
            )
    }
}

// Scale maps data to unit value
// AestheticScale maps DVs OR enums (?) to aesthetics : shape, colour, ...
// Coordinate maps UnitValues to screen coordinates
// Guide overlays the chart to 'guide' the user's interpretation, so it indicates how the   UnitValues appear on the chart




#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
