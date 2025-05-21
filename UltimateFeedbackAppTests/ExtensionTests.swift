//
//  ExtensionTests.swift
//  UltimateFeedbackAppTests
//
//  Created by Rob Ranf on 12/19/24.
//

import CoreData
@testable import UltimateFeedbackApp
import XCTest

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

    func testIssueTagsUnwrap() {
        let tag = Tag(context: moc)
        let issue = Issue(context: moc)

        XCTAssertEqual(issue.issueTags.count, 0, "A new issue should have no tags")
        issue.addToTags(tag)

        XCTAssertEqual(issue.issueTags.count, 1,
                       "Adding 1 tag to an issue should result in issueTags having count 1")
    }

    func testIssueTagsList() {
        let tag = Tag(context: moc)
        let issue = Issue(context: moc)

        tag.name = "My Tag"
        issue.addToTags(tag)

        XCTAssertEqual(issue.issueTagsList, "My Tag",
                       "Adding 1 tag to an issue should make issueTagsList be My Tag.")
    }

    func testIssueSortingIsStable() {
        let issue1 = Issue(context: moc)
        issue1.title = "B Issue"
        issue1.creationDate = .now

        let issue2 = Issue(context: moc)
        issue2.title = "B Issue"
        issue2.creationDate = .now.addingTimeInterval(1)

        let issue3 = Issue(context: moc)
        issue3.title = "A Issue"
        issue3.creationDate = .now.addingTimeInterval(100)

        let allIssues = [issue1, issue2, issue3]
        let sorted = allIssues.sorted()

        XCTAssertEqual([issue3, issue1, issue2], sorted,
                       "Sorting issue arrays should use name then creation date.")
    }
}
