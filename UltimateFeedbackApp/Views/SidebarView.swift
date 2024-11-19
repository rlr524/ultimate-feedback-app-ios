//
//  SidebarView.swift
//  UltimateFeedbackApp
//
//  Created by Rob Ranf on 5/25/23.
//

import SwiftUI

struct SidebarView: View {
    @EnvironmentObject var dc: DataController
    @State private var tagToRename: Tag?
    @State private var renamingTag = false
    @State private var tagName = ""
    @State private var showingAwards = false
    // The FetchRequest prop wrapper ensures SwiftUI updates
    // the tag list automatically as tags are added or removed
    @FetchRequest(sortDescriptors: [SortDescriptor(\.name)]) var tags: FetchedResults<Tag>
    var tagFilters: [Filter] {
        tags.map { tag in
            Filter(id: tag.tagID, name: tag.tagName, icon: "tag", tag: tag)
        }
    }
    let smartFilters: [Filter] = [.all, .recent]

    var body: some View {
        List(selection: $dc.selectedFilter) {
            Section("Smart Filters") {
                ForEach(smartFilters) { filter in
                    NavigationLink(value: filter) {
                        Label(LocalizedStringKey(filter.name), systemImage: filter.icon)
                    }
                }
            }
            Section("Tags") {
                ForEach(tagFilters) { filter in
                    NavigationLink(value: filter) {
                        Label(filter.name, systemImage: filter.icon)
                            .badge(filter.activeIssuesCount)
                            .contextMenu {
                                Button {
                                    rename(filter)
                                } label: {
                                    Label("Rename", systemImage: "pencil")
                                }

                                Button(role: .destructive) {
                                    delete(filter)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                            .accessibilityElement()
                            .accessibilityLabel(filter.name)
                            // Using automatic grammar agreement, which is part of the Foundation
                            // framework, to adjust "issue" to "issues" when the number of
                            // issues is plural.
                            .accessibilityHint("^[\(filter.activeIssuesCount) issue](inflect: true)")
                    }
                }
                .onDelete(perform: delete)
            }
        }
        .toolbar {
            SidebarViewToolbar(showingAwards: $showingAwards)
        }
        .alert("Rename tag", isPresented: $renamingTag) {
            Button("OK", action: completeRename)
            Button("Cancel", role: .cancel) {}
            TextField("New name", text: $tagName)
        }
        .navigationTitle("Filters")
        .sheet(isPresented: $showingAwards, content: AwardsView.init)
    }

    func delete(_ offsets: IndexSet) {
        for offset in offsets {
            let item = tags[offset]
            dc.delete(item)
        }
    }

    func rename(_ filter: Filter) {
        tagToRename = filter.tag
        tagName = filter.name
        renamingTag = true
    }

    func completeRename() {
        tagToRename?.name = tagName
        dc.save()
    }

    func delete(_ filter: Filter) {
        guard let tag = filter.tag else { return }
        dc.delete(tag)
        dc.save()
    }
}

#Preview {
    SidebarView()
        .environmentObject(DataController.preview)
}
