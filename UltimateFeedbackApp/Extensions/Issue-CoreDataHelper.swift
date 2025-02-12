//
//  Issue-CoreDataHelpers.swift
//  UltimateFeedbackApp
//
//  Created by Rob Ranf on 3/21/24.
//

import Foundation

extension Issue: Comparable {

    // swiftlint:disable:next operator_whitespace
    public static func <(lhs: Issue, rhs: Issue) -> Bool {
        let left = lhs.issueTitle.localizedLowercase
        let right = rhs.issueTitle.localizedLowercase

        if left == right {
            return lhs.creationDate ?? Date.now < rhs.creationDate ?? Date.now - 1
        } else {
            return left < right
        }
    }

    var issueTitle: String {
        get { title ?? "" }
        set { title = newValue }
    }

    var issueContent: String {
        get { content ?? "" }
        set { content = newValue }
    }

    var issueModificationDate: Date {
        modificationDate ?? .now
    }

    static var example: Issue {
        let controller = DataController(inMemory: true)
        let viewContext = controller.container.viewContext

        let issue = Issue(context: viewContext)
        issue.title = "Example Issue"
        issue.content = "This is an example issue."
        issue.priority = 2
        issue.creationDate = .now

        return issue
    }

    var issueTags: [Tag] {
        let result = tags?.allObjects as? [Tag] ?? []
        return result.sorted()
    }

    var issueStatus: String {
        if completed {
            return NSLocalizedString("Closed", comment: "This issue has been resolved by the user.")
        } else {
            return NSLocalizedString("Open", comment: "This issue is currently unresolved.")
        }
    }

    var issueTagsList: String {
        let noTags = NSLocalizedString("No tags", comment: "This user has not created any tags.")

        guard let tags else { return noTags }

        if tags.count == 0 {
            return noTags
        } else {
            return issueTags.map(\.tagName).formatted()
        }
    }
}
