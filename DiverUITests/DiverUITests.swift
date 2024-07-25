//
//  DiverUITests.swift
//  DiverUITests
//
//  Created by Gerald Burke on 7/15/24.
//

import XCTest

final class DiverUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
        XCUIDevice.shared.orientation = .portrait
    }

    override func tearDownWithError() throws {
        /// Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        /// UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launchArguments = ["ui-testing"]
        app.launch()
        /// Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
