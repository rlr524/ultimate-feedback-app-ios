//
//  IssueRowView.swift
//  UltimateFeedbackApp
//
//  Created by Rob Ranf on 3/22/24.
//

import SwiftUI

struct IssueRowView: View {
    @EnvironmentObject var dataController: DataController
    @StateObject var vm: ViewModel

    init(issue: Issue) {
        let vm = ViewModel(issue: issue)
        _vm = StateObject(wrappedValue: vm)
    }

    var body: some View {
        NavigationLink(value: vm.issue) {
            HStack {
                Image(systemName: "exclamationmark.circle")
                    .imageScale(.large)
                    .opacity(vm.iconOpacity)
                    .accessibilityIdentifier(vm.iconIdentifier)

                VStack(alignment: .leading) {
                    Text(vm.issue.issueTitle)
                        .font(.headline)
                        .lineLimit(1)

                    Text(vm.issue.issueTagsList)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
                Spacer()

                VStack(alignment: .trailing) {
                    Text(vm.creationDate.formatted())
                        .accessibilityLabel(vm.accessiblityCreationDate)
                        .font(.subheadline)

                    if vm.issue.completed {
                        Text("CLOSED")
                            .font(.body.smallCaps())
                    }
                }
                .foregroundStyle(.secondary)
            }
        }
        .accessibilityHint(vm.accessibilityHint)
        .accessibilityIdentifier(vm.issueTitle)
    }
}

#Preview {
    IssueRowView(issue: Issue.example)
}
