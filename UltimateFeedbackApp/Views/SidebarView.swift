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
                        Label(filter.name, systemImage: filter.icon)
                    }
                }
            }
            Section("Tags") {
                ForEach(tagFilters) { filter in
                    NavigationLink(value: filter) {
                        Label(filter.name, systemImage: filter.icon)
                            .badge(filter.tag?.tagActiveIssues.count ?? 0)
                            .contextMenu {
                                Button {
                                    rename(filter)
                                } label: {
                                    Label("Rename", systemImage: "pencil")
                                }
                            }
                    }
                }
                .onDelete(perform: delete)
            }
            
        }
        .toolbar {
#if DEBUG
            Button {
                dc.deleteAll()
                dc.createSampleData()
            } label: {
                Label("ADD SAMPLES", systemImage: "flame")
            }
#endif
            
            Button(action: dc.newTag) {
                Label("Add tag", systemImage: "plus")
            }
        }
        .alert("Rename tag", isPresented: $renamingTag) {
            Button("OK", action: completeRename)
            Button("Cancel", role: .cancel) {}
            TextField("New name", text: $tagName)
        }
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
}

#Preview {
    SidebarView()
        .environmentObject(DataController.preview)
}
