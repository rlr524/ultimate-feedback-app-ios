//
//  ExtensionTests.swift
//  UltimateFeedbackAppTests
//
//  Created by Rob Ranf on 12/19/24.
//

import XCTest
import CoreData
@testable import UltimateFeedbackApp

final class ExtensionTests: BaseTestCase {
    func testIssueTitleUnwrap() {
        let issue = Issue(context: moc)

        issue.title = "Example issue"
        XCTAssertEqual(issue.issueTitle, "Example issue",
                       "Changing title should also change issueTitle")

        issue.issueTitle = "Updated example issue"
        XCTAssertEqual(issue.issueTitle, "Updated example issue",
                       "Changing issueTitle should also change title")
    }

    func testIssueContentUnwrap() {
        let issue = Issue(context: moc)

        issue.content = "Example issue content"
        XCTAssertEqual(issue.issueContent, "Example issue content",
                       "Changing content should also change issueContent")

        issue.issueContent = "Updated example issue content"
        XCTAssertEqual(issue.content, "Updated example issue content",
                       "Changing issueContent should also change content")
    }

    func testIssueCreationDateUnwrap() {
        let issue = Issue(context: moc)
        let testDate = Date.now

        issue.creationDate = testDate
        XCTAssertEqual(issue.issueCreationDate, testDate,
                       "Changing creation date should also change issueCreationDate")
    }
}
