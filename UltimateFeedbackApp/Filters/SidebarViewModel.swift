//
//  SidebarViewModel.swift
//  UltimateFeedbackApp
//
//  Created by Rob Ranf on 1/21/25.
//

import Foundation
import CoreData
import SwiftUI

extension SidebarView {
    class ViewModel: ObservableObject {
        var dc: DataController
        @Published var tagToRename: Tag?
        @Published var renamingTag = false
        @Published var tagName = ""
        @Published var showingAwards = false
        // The FetchRequest prop wrapper ensures SwiftUI updates
        // the tag list automatically as tags are added or removed
        @FetchRequest(sortDescriptors: [SortDescriptor(\.name)]) var tags: FetchedResults<Tag>
        var tagFilters: [Filter] {
            tags.map { tag in
                Filter(id: tag.tagID, name: tag.tagName, icon: "tag", tag: tag)
            }
        }

        init(dc: DataController) {
            self.dc = dc
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
}
