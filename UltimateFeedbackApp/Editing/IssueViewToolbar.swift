//
//  IssueViewToolbar.swift
//  UltimateFeedbackApp
//
//  Created by Rob Ranf on 11/26/24.
//

import SwiftUI

struct IssueViewToolbar: View {
    @EnvironmentObject var dc: DataController
    @ObservedObject var issue: Issue

    var openCloseButtonText: LocalizedStringKey {
        issue.completed ? "Re-open Issue" : "Close Issue"
    }

    var body: some View {
        Menu {
            Button {
                UIPasteboard.general.string = issue.issueTitle
            } label: {
                Label("Copy Issue Title", systemImage: "doc.on.doc")
            }

            Button {
                issue.completed.toggle()
                dc.save()
            } label: {
                Label(openCloseButtonText, systemImage: "bubble.left.and.exclamationmark.bubble.right")
            }

            Section("Tags") {
                TagsMenuView(issue: issue)
            }
        } label: {
            Label("Actions", systemImage: "ellipsis.circle")
        }
    }
}

#Preview {
    IssueViewToolbar(issue: .example)
}
