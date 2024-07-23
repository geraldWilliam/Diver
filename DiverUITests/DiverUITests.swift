//
//  DiverUITests.swift
//  DiverUITests
//
//  Created by Gerald Burke on 7/15/24.
//

import XCTest

final class DiverUITests: XCTestCase {

    override func setUpWithError() throws {
        /// In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        /// In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good
        /// place to do this.
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

        let homeNavigationBar = XCUIApplication().navigationBars["Home"]
        homeNavigationBar/*@START_MENU_TOKEN@*/.buttons["Compose"]/*[[".otherElements[\"Compose\"].buttons[\"Compose\"]",".buttons[\"Compose\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        homeNavigationBar.staticTexts["Home"].tap()

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
