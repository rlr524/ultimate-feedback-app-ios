//
//  ContentView.swift
//  UltimateFeedbackApp
//
//  Created by Rob Ranf on 5/20/23.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var vm: ViewModel

    init(dc: DataController) {
        let vm = ViewModel(dc: dc)
        _vm = StateObject(wrappedValue: vm)
    }

    var body: some View {
        List(selection: $vm.dc.selectedIssue) {
            ForEach(vm.dc.issuesForSelectedFilter()) { issue in
                IssueRow(issue: issue)
            }
            .onDelete(perform: vm.delete)
        }
        .navigationTitle("Issues")
        .searchable(text: $vm.dc.filterText, tokens: $vm.dc.filterTokens,
                    suggestedTokens: .constant(vm.dc.suggestedFilterTokens),
                    prompt: "Filter issues, or type # to add tags") { tag in Text(tag.tagName) }
            .toolbar(content: ContentViewToolbar.init)
    }


}

#Preview {
    ContentView(dc: .preview)
}
