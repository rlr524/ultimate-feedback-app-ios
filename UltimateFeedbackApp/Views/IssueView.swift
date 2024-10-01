//
//  IssueView.swift
//  UltimateFeedbackApp
//
//  Created by Rob Ranf on 3/27/24.
//

import SwiftUI

struct IssueView: View {
    @ObservedObject var issue: Issue
    @EnvironmentObject var dataController: DataController

    var body: some View {
        Form {
            Section {
                VStack(alignment: .leading) {
                    TextField("Title", text: $issue.issueTitle,
                              prompt: Text("Enter the issue title here"))
                    .font(.title)

                    // Use markdown **text** to style (bold in this case) the text inside a string
                    // but not apply the style to the entire string as would happen with a modifier. If
                    // you actually wanted to print the **, precede the string with the verbatim:
                    // initializer, which will not apply to the string interpolation.
                    Text("**Modified:** \(issue.issueModificationDate.formatted(date: .long, time: .shortened))")
                        .foregroundStyle(.secondary)

                    Text("**Status:** \(issue.issueStatus)")
                        .foregroundStyle(.secondary)
                }

                Picker("Priority", selection: $issue.priority) {
                    Text("Low").tag(Int16(0))
                    Text("Medium").tag(Int16(1))
                    Text("High").tag(Int16(2))
                }

                Menu {
                    // show selected tags first
                    ForEach(issue.issueTags) { tag in
                        Button {
                            issue.removeFromTags(tag)
                        } label: {
                            Label(tag.tagName, systemImage: "checkmark")
                        }
                    }

                    let otherTags = dataController.missingTags(from: issue)

                    if otherTags.isEmpty == false {
                        Divider()

                        Section("Add Tags") {
                            ForEach(otherTags) { tag in
                                Button(tag.tagName) {
                                    issue.addToTags(tag)
                                }
                            }
                        }
                    }
                } label: {
                    Text(issue.issueTagsList)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .animation(nil, value: issue.issueTagsList)
                }
            }

            Section {
                VStack(alignment: .leading) {
                    Text("Basic Information")
                        .font(.title2)
                        .foregroundStyle(.secondary)

                    TextField("Description", text: $issue.issueContent,
                              prompt: Text("Enter the issue description here"), axis: .vertical)
                }
            }
        }
        .disabled(issue.isDeleted)
        // We need to use onReceive() to watch for the issue announcing changes using @Published.
        // If you remember, @Published internally calls the objectWillChange publisher that comes
        // built into any class that conforms to ObservableObject (which our DataController does).
        // So, we can use onReceive() to watch that for announcements, and call queueSave()
        // whenever a change notification comes in.
        .onReceive(issue.objectWillChange) { _ in
            dataController.queueSave()
        }
    }
}

#Preview {
    IssueView(issue: .example)
}
