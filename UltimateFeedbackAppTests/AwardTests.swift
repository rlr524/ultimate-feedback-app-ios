//
//  AwardTests.swift
//  UltimateFeedbackAppTests
//
//  Created by Rob Ranf on 12/9/24.
//

import XCTest
import CoreData
@testable import UltimateFeedbackApp

final class AwardTests: BaseTestCase {
    let awards = Award.allAwards

    func testAwardIDMatchesName() {
        for award in awards {
            XCTAssertEqual(award.id, award.name, "Award ID should always match its name.")
        }
    }

    func testNewUserHasNoAwards() {
        for award in awards {
            XCTAssertFalse(dc.hasEarned(award: award), "New users should have no awards")
        }
    }

    func testCreatingIssuesUnlocksAwards() {
        let values = [1, 10, 20, 50, 100, 250, 500, 1000]

        for (idx, value) in values.enumerated() {
            var issues = [Issue]()

            for _ in 0..<value {
                let issue = Issue(context: moc)
                issues.append(issue)
            }

            let matches = awards.filter { award in
                award.criteria == "issues" && dc.hasEarned(award: award)
            }

            XCTAssertEqual(matches.count, idx + 1,
                           "Adding \(value) issues should unlock \(idx + 1) awards.")

            dc.deleteAll()
        }
    }

    func testClosingIssuesUnlocksAwards() {
        let values = [1, 10, 20, 50, 100, 250, 500, 1000]

        for (idx, value) in values.enumerated() {
            var issues = [Issue]()

            for _ in 0..<value {
                let issue = Issue(context: moc)
                issue.completed = true
                issues.append(issue)
            }

            let matches = awards.filter { award in
                award.criteria == "closed" && dc.hasEarned(award: award)
            }

            XCTAssertEqual(matches.count, idx + 1,
                           "Completing \(value) issues should unlock \(idx + 1) awards.")

            dc.deleteAll()
        }
    }
}
