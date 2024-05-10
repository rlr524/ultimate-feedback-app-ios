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
            .toolbar {
                Menu {
                    Button(dc.filterEnabled ? "Turn Filter Off" : "Turn Filter On") {
                        dc.filterEnabled.toggle()
                    }
                    
                    Divider()
                    
                    Menu("Sort By") {
                        Picker("Sort By", selection: $dc.sortType) {
                            Text("Date Created").tag(SortType.dateCreated)
                            Text("Date Modified").tag(SortType.dateModified)
                        }
                        
                        Divider()
                        
                        Picker("Sort Order", selection: $dc.sortNewestFirst) {
                            Text("Newest to Oldest").tag(true)
                            Text("Oldest to Newest").tag(false)
                        }
                    }
                    
                    Picker("Status", selection: $dc.filterStatus) {
                        Text("All").tag(Status.all)
                        Text("Open").tag(Status.open)
                        Text("Closed").tag(Status.closed)
                    }
                    .disabled(dc.filterEnabled == false)
                    
                    Picker("Priority", selection: $dc.filterPriority) {
                        Text("All").tag(-1)
                        Text("Low").tag(0)
                        Text("Medium").tag(1)
                        Text("High").tag(2)
                    }
                    .disabled(dc.filterEnabled == false)
                } label: {
                    Label("Filter", systemImage: "line.3.horizontal.decrease.circle")
                        .symbolVariant(dc.filterEnabled ? .fill : .none)
                }
            }
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
