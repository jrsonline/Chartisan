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

let longLabels = ["Q1 2018", "Q2 2018", "Q3 2018", "Q4 2018","Q1 2019"]
let medLabels = ["Q1'18", "Q2'18", "Q3'18", "Q4'18","Q1'19"]
let shortLabels = ["Q1","Q2","Q3","Q4","Q1"]
let labelChoice = medLabels

struct TestData { let y1,y2,y3: Double?; let type: DType; let label: String; let id: Int }
let testData : [TestData] = [ TestData(y1: nil, y2: 2,  y3: 4, type: .b, label:labelChoice[0], id:1),
                              TestData(y1: -2, y2: 6,  y3: 1, type: .a, label:labelChoice[1], id:2),
                              TestData(y1:  5, y2: 3, y3: 2, type: .b, label:labelChoice[2], id:3),
                              TestData(y1:  1, y2: 5, y3: nil, type: .a, label:labelChoice[3], id:4),
                              TestData(y1: 2, y2: -3, y3: 6, type: .a, label:labelChoice[4], id:5)]

struct ContentView: View {
    
    var body : some View {
        VStack {
            Chart(data:testData,
                  labels: \.label,
                  coords: Cartesian(axes:[.yAxis : (.labelGuide,"Quarter"),
                                          .xAxis : (.linearGuide,"$M")  ]),
                  plots:[ BarChart(sizeOrNil: \.y1, onto: .xAxis, annotation: "Capital", colour: .fixed(.yellow) ),
                          BarChart(sizeOrNil: \.y2, onto: .xAxis,annotation: "People", colour: .flag(\.type.isA, ifTrue: .blue, ifFalse: .pink) ),
                          BarChart(sizeOrNil: \.y3, onto: .xAxis, annotation: "Assets", colour: .posNegNil(\.y3, pos: .green, neg:.red)),
                          //                     LineChart(height: \.y3, guide: .y2ndAxis,  shape: .circle(/radius: \.capital), annotation: "Overage", colour: .custom({ $0.y3 > 0 ? .red : .green }))
                ],
                  blendMode:  .stack
            )
            
            Chart(data:testData,
                  labels: \.label,
                  coords: Cartesian(axes:[.xAxis : (.labelGuide,"Quarter"),
                                          .yAxis : (.linearGuide,"$M")  ]),
                  plots:[ BarChart(sizeOrNil: \.y1, onto: .yAxis, annotation: "Capital", colour: .fixed(.yellow) ),
                          BarChart(sizeOrNil: \.y2, onto: .yAxis,annotation: "People", colour: .flag(\.type.isA, ifTrue: .blue, ifFalse: .pink) ),
                          BarChart(sizeOrNil: \.y3, onto: .yAxis, annotation: "Assets", colour: .posNegNil(\.y3, pos: .green, neg:.red)),
                          //                     LineChart(height: \.y3, guide: .y2ndAxis,  shape: .circle(/radius: \.capital), annotation: "Overage", colour: .custom({ $0.y3 > 0 ? .red : .green }))
                ],
                  blendMode: .stack
            )
            
            Chart(data:testData,
                  labels: \.label,
                  coords: Cartesian(axes:[.xAxis : (.labelGuide,"Quarter"),
                                          .yAxis : (.linearGuide,"$M")  ]),
                  plots:[ BarChart(sizeOrNil: \.y1, onto: .yAxis, annotation: "Capital", colour: .fixed(.yellow) ),
                          BarChart(sizeOrNil: \.y2, onto: .yAxis,annotation: "People", colour: .flag(\.type.isA, ifTrue: .blue, ifFalse: .pink) ),
                          BarChart(sizeOrNil: \.y3, onto: .yAxis, annotation: "Assets", colour: .posNegNil(\.y3, pos: .green, neg:.red)),
                          //                     LineChart(height: \.y3, guide: .y2ndAxis,  shape: .circle(/radius: \.capital), annotation: "Overage", colour: .custom({ $0.y3 > 0 ? .red : .green }))
                ],
                  blendMode: .fdodge(0.75)
            )
        }
        .environment(\.viewAnnotation, debugViewAnnotation)
        
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
