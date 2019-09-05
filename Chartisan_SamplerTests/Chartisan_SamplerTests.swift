//
//  Chartisan_SamplerTests.swift
//  Chartisan_SamplerTests
//
//  Created by RedPanda on 21-Aug-19.
//  Copyright © 2019 strictlyswift. All rights reserved.
//

import XCTest
@testable import Chartisan_Sampler

extension CGPoint {
    func quantizedCompare(to other: CGPoint) -> Bool {
        return ((self.x-other.x)*(self.x-other.x))+((self.y-other.y)*(self.y-other.y)) < 0.5
    }
}

func XCTAssertEqualCGPoints(_ first: CGPoint, _ second: CGPoint, file: StaticString = #file, line: UInt = #line) {
    XCTAssert( first.quantizedCompare(to: second), "Expected point \(first), got point \(second)", file: file, line: line)
}

func XCTAssertEqualCGRects(_ first: CGRect, _ second: CGRect, file: StaticString = #file, line: UInt = #line) {
    XCTAssert( first.origin.quantizedCompare(to: second.origin), "Expected point \(first), got point \(second)", file: file, line: line)
    XCTAssert( abs(first.width - second.width) < 0.5, "Expected width \(first.width), got width \(second.width)", file: file, line: line)
    XCTAssert( abs(first.height - second.height) < 0.5, "Expected height \(first.height), got height \(second.height)", file: file, line: line)
}

struct TestData { let y1,y2,y3: Double?; let type: DType; let label: String; let id: Int }

class Chartisan_SamplerTests: XCTestCase {
    static let labelChoice =  ["Q1'18", "Q2'18", "Q3'18", "Q4'18","Q1'19"]
    let testData : [TestData] =
        [ TestData(y1: nil, y2: 2,  y3: 4, type: .b, label:labelChoice[0], id:1),
          TestData(y1: -2, y2: 6,  y3: 1, type: .a, label:labelChoice[1], id:2),
          TestData(y1:  5, y2: 3, y3: 2, type: .b, label:labelChoice[2], id:3),
          TestData(y1:  1, y2: 5, y3: nil, type: .a, label:labelChoice[3], id:4),
          TestData(y1: 2, y2: -3, y3: 6, type: .a, label:labelChoice[4], id:5)
        ]
    
    let plots : [BarChart<TestData, Cartesian>] =
        [ BarChart(sizeOrNil: \.y1, onto: .xAxis, annotation: "Capital", colour: .fixed(.yellow) ),
          BarChart(sizeOrNil: \.y2, onto: .xAxis, annotation: "People", colour: .flag(\.type.isA, ifTrue: .blue, ifFalse: .pink) ),
          BarChart(sizeOrNil: \.y3, onto: .xAxis, annotation: "Assets", colour: .posNegNil(\.y3, pos: .green, neg:.red)),
        ]
    
    let cartesianScale = Cartesian(
        axes:[.yAxis : (.labelGuide,"Quarter"),
              .xAxis : (.linearGuide,"$M")  ]
    )
    
    override func setUp() {

    }

    override func tearDown() {
        
    }

    func testXAxisLabelPlacement1() {
        let labelPositions: [UnitValue] = [0.0, 1.0/3.0, 2.0/3.0, 1.0].map (UnitValue.init)
        let maxAxisWidth : CGFloat = 140
        let xAxisGuide = CGRect(x:60, y:140, width:140, height:60)
        let labelSet =
            RotatableLabelSet(labels: ["-5","0","5","10"],
                              containerSize: CGSize(width:35, height:20),
                              rotatedContainerSize: CGSize(width:20, height: 40),
                              containerCentre: { idx in
                                CGPoint( x: labelPositions[idx].factor(by: maxAxisWidth) + xAxisGuide.minX,
                                         y: xAxisGuide.minY)},
                              alignWithSteps: RotatableLabelSet.StepAlignment.unaligned,
                              alignmentPreference: RotatableLabelSet.RotatableAlignmentPreference(normal: .top, rotated: .top))
        
        XCTAssertEqual( labelSet.frames.count, 4)
        
        XCTAssertEqualCGRects( labelSet.frames["0"]!, CGRect(x:60, y:154, width:18, height:20) )
        XCTAssertEqualCGRects( labelSet.frames["1"]!, CGRect(x:106, y:154, width:18, height:20) )
        XCTAssertEqualCGRects( labelSet.frames["2"]!, CGRect(x:153, y:154, width:18, height:20) )
        XCTAssertEqualCGRects( labelSet.frames["3"]!, CGRect(x:200, y:154, width:18, height:20) )
    }

    func testChartSections() {

        let dummyPlacementScale = PlacedDeterminedScales<CartesianGuidePlacement>()
        let chartSections = cartesianScale.determineChartSections(
            frame: CGRect(x:0, y:0, width:200, height: 200),
            fullArea: CGSize(width: 200, height: 200),
            plotPercentage: 0.7,
            forScale: dummyPlacementScale)
        
        XCTAssertEqualCGRects(chartSections.plotArea, CGRect(x:60, y:0, width:140, height:140))
        XCTAssertEqualCGRects(chartSections.guidePlacementAreas[.xAxis]! , CGRect(x:60, y:140, width:140, height:60))
        XCTAssertEqualCGRects(chartSections.guidePlacementAreas[.yAxis]! , CGRect(x:0, y:0, width:60, height:140))
    }
    
    func testGuideScaleDetermination() {
        let determinedGuideScales = cartesianScale.determineGuideScales(
            data: testData,
            plots: plots,
            labels: Chartisan_SamplerTests.labelChoice
        )
        
        // Check label on y axis
        guard let ls = determinedGuideScales.placedAt[.yAxis]!.0.getLabelScale() as? LabelScale else { XCTFail("YAxis does not have LabelScale!"); return }
        XCTAssertEqual(ls, LabelScale(labels: Chartisan_SamplerTests.labelChoice) )
        
        // check linear scale on x axis
        guard let gs = determinedGuideScales.placedAt[.xAxis]!.0.getGuideScale() as? LinearScale else { XCTFail("XAxis does not have LinearScale!"); return }
        let expectedChartSteps = [-4,-2,0,2,4,6].enumerated().map { (nx) -> ChartStep in
            let (n,x) = nx
            return ChartStep(id: n, label: "\(x)", position: UnitValue(n.asDouble/6.0), width: UnitValue(0.2))
        }
        XCTAssertEqual(gs.min, -4)
        XCTAssertEqual(gs.max, 6)
        XCTAssertEqual(gs.chartSteps, expectedChartSteps)
    }
    
//    func testPerformanceExample() {
//        // This is an example of a performance test case.
//        measure(metrics: [XCTCPUMetric()]) {
//            // Put the code whose CPU performance you want to measure here.
//        }
//    }

}
