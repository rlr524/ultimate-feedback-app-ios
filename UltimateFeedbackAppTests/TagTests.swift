//
//  TagTests.swift
//  UltimateFeedbackAppTests
//
//  Created by Rob Ranf on 12/9/24.
//

import CoreData
import XCTest
@testable import UltimateFeedbackApp

final class TagTests: BaseTestCase {
    func testCreatingTagsAndIssues() {
        let count = 10
        let issueCount = count * count

        for _ in 0..<count {
            let tag = Tag(context: moc)

            for _ in 0..<count {
                let issue = Issue(context: moc)
                tag.addToIssues(issue)
            }
        }
        XCTAssertEqual(dc.count(for: Tag.fetchRequest()), count, "Expected \(count) tags.")
        XCTAssertEqual(dc.count(for: Issue.fetchRequest()), issueCount,
                       "Expected \(issueCount) issues")
    }

    func testDeletingTagFollowsNullifyDeleteRule() throws {
        dc.createSampleData()

        let request = NSFetchRequest<Tag>(entityName: "Tag")
        let tags = try moc.fetch(request)

        dc.delete(tags[0])

        // We're testing that the nullfy delete rule is in place (if you delete a parent object
        // from CoreData, don't delete related child objects) so when we created the sample data
        // above, which creates 5 tags with 10 issues each, we expect 1 tag to be deleted but no
        // issues to be deleted when we run dc.delete on the first tag in the tags array.
        XCTAssertEqual(dc.count(for: Tag.fetchRequest()), 4, "Expected 4 tags after deleting 1.")
        XCTAssertEqual(dc.count(for: Issue.fetchRequest()), 50,
                       "Expected 50 issues after deleting a tag.")
    }
}
