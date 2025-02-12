//
//  IssueRowViewModel.swift
//  UltimateFeedbackApp
//
//  Created by Rob Ranf on 2/5/25.
//

import Foundation

extension IssueRowView {
    @dynamicMemberLookup
    class ViewModel: ObservableObject {
        let issue: Issue

        subscript<Value>(dynamicMember keyPath: KeyPath<Issue, Value>) -> Value {
            issue[keyPath: keyPath]
        }

        init(issue: Issue) {
            self.issue = issue
        }

        var iconOpacity: Double {
            issue.priority == 2 ? 1 : 0
        }

        var iconIdentifier: String {
            issue.priority == 2 ? "\(issue.priority) High Priority" : ""
        }

        var accessibilityHint: String {
            issue.priority == 2 ? "High Priority" : ""
        }

        var creationDate: Date {
            issue.creationDate ?? .now
        }

        var accessiblityCreationDate: String {
            issue.creationDate?.formatted(date: .abbreviated, time: .omitted) ?? ""
        }
    }
}

