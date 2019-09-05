//
//  Chartisan_SamplerUITests.swift
//  Chartisan_SamplerUITests
//
//  Created by RedPanda on 1-Sep-19.
//  Copyright © 2019 strictlyswift. All rights reserved.
//

import XCTest

class Chartisan_SamplerUITests: XCTestCase {
    var app: XCUIApplication!
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        app = XCUIApplication()
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testDidWeGetChartCoordinates() {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()

    }

    func testLaunchPerformance() {
        // This measures how long it takes to launch your application from the home screen.
        measure(metrics: [XCTOSSignpostMetric.applicationLaunch]) {
            XCUIApplication().launch()
        }
    }
}
