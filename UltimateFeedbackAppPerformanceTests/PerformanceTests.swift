//
//  PerformanceTests.swift
//  UltimateFeedbackAppPerformanceTests
//
//  Created by Rob Ranf on 12/20/24.
//

import XCTest
@testable import UltimateFeedbackApp

final class PerformanceTests: BaseTestCase {
    func testAwardCalculationPerformance() {
        // Create a significant amount of test data
        for _ in 1...1000 {
            dc.createSampleData()
        }

        // Simulate lots of awards to check
        let awards = Array(repeating: Award.allAwards, count: 100).joined()
        XCTAssertEqual(awards.count, 2000,
                       "This checks the awards count is constant. Change this if you add awards.")

        measure {
            _ = awards.filter(dc.hasEarned)
        }
    }
}
