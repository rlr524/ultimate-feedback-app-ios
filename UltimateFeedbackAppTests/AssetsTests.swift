//
//  AssetsTests.swift
//  UltimateFeedbackAppTests
//
//  Created by Rob Ranf on 12/9/24.
//

import XCTest
@testable import UltimateFeedbackApp

final class AssetsTests: BaseTestCase {
    func testColorsExist() {
        let allColors = ["c_Dark Blue", "c_Dark Gray", "c_Gold", "c_Gray", "c_Green",
                         "c_Light Blue", "c_Midnight", "c_Orange", "c_Pink", "c_Purple",
                         "c_Red", "c_Teal"]

        for color in allColors {
            XCTAssertNotNil(UIColor(named: color),
                            "Failed to load color '\(color)' from asset catalog")
        }
    }

    func testAwardsLoadCorrectly() {
        XCTAssertTrue(Award.allAwards.isEmpty == false, "Failed to load awards from JSON.")
    }
}
