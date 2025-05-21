//
//  ContentViewToolbarView.swift
//  UltimateFeedbackApp
//
//  Created by Rob Ranf on 11/26/24.
//

import SwiftUI

struct ContentViewToolbarView: View {
    @EnvironmentObject var dc: DataController

    var body: some View {
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

        Button(action: dc.newIssue) {
            Label("New Issue", systemImage: "square.and.pencil")
        }
    }
}

#Preview {
    ContentViewToolbarView()
}
