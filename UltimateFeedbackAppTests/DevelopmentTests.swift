//
//  DevelopmentTests.swift
//  UltimateFeedbackAppTests
//
//  Created by Rob Ranf on 12/11/24.
//

import XCTest
import CoreData
@testable import UltimateFeedbackApp

final class DevelopmentTests: BaseTestCase {
    func testSampleDataCreation() {
        dc.createSampleData()

        XCTAssertEqual(dc.count(for: Tag.fetchRequest()), 5, "There should be 5 sample tags.")
        XCTAssertEqual(dc.count(for: Issue.fetchRequest()), 50, "There should be 50 sample issues.")
    }

    func testDeleteAllClearsEverything() {
        dc.createSampleData()
        dc.deleteAll()

        XCTAssertEqual(dc.count(for: Tag.fetchRequest()), 0, "deleteAll() should leave 0 tags.")
        XCTAssertEqual(dc.count(for: Issue.fetchRequest()), 0, "deleteAll() should leave 0 issues.")
    }

    func testExampleTagsHaveZeroIssues() {
        let tag = Tag.example
        XCTAssertEqual(tag.issues?.count, 0, "The example tag should have 0 issues.")
    }

    func testExampleIssueHasHighPriority() {
        let issue = Issue.example
        XCTAssertEqual(issue.priority, 2, "The example issue should be high priority.")
    }
}
