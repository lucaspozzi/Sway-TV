//
//  Sway_Radio_DJ_CompanionUITestsLaunchTests.swift
//  Sway Radio DJ CompanionUITests
//
//  Created by Lucas Pozzi de Souza on 8/8/23.
//

import XCTest

final class Sway_Radio_DJ_CompanionUITestsLaunchTests: XCTestCase {

    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testLaunch() throws {
        let app = XCUIApplication()
        app.launch()

        // Insert steps here to perform after app launch but before taking a screenshot,
        // such as logging into a test account or navigating somewhere in the app

        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Launch Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
