//
//  ContentView.swift
//  UltimateFeedbackApp
//
//  Created by Rob Ranf on 5/20/23.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var dc: DataController

    var body: some View {
        List(selection: $dc.selectedIssue) {
            ForEach(dc.issuesForSelectedFilter()) { issue in
                IssueRow(issue: issue)
            }
            .onDelete(perform: delete)
        }
        .navigationTitle("Issues")
        .searchable(text: $dc.filterText, tokens: $dc.filterTokens,
                    suggestedTokens: .constant(dc.suggestedFilterTokens),
                    prompt: "Filter issues, or type # to add tags") { tag in Text(tag.tagName) }
            .toolbar(content: ContentViewToolbar.init)
    }

    func delete(_ offsets: IndexSet) {
        let issues = dc.issuesForSelectedFilter()

        for offset in offsets {
            let item = issues[offset]
            dc.delete(item)
        }
    }
}

#Preview {
    ContentView()
}
