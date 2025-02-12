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
        List(selection: $vm.selectedIssue) {
            ForEach(vm.dc.issuesForSelectedFilter()) { issue in
                IssueRowView(issue: issue)
            }
            .onDelete(perform: vm.delete)
        }
        .navigationTitle("Issues")
        .searchable(text: $vm.filterText, tokens: $vm.filterTokens,
                    suggestedTokens: .constant(vm.suggestedFilterTokens),
                    prompt: "Filter issues, or type # to add tags") { tag in Text(tag.tagName) }
            .toolbar(content: ContentViewToolbarView.init)
    }


}

#Preview {
    ContentView(dc: .preview)
}
