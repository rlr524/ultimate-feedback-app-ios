//
//  SidebarViewModel.swift
//  UltimateFeedbackApp
//
//  Created by Rob Ranf on 1/21/25.
//

import Foundation
import CoreData

extension SidebarView {
    class ViewModel: NSObject, ObservableObject, NSFetchedResultsControllerDelegate {
        var dc: DataController
        @Published var tagToRename: Tag?
        @Published var renamingTag = false
        @Published var tagName = ""
        @Published var showingAwards = false
        // The fetched results controller is private because it's an implementation detail.
        private let tagsController: NSFetchedResultsController<Tag>
        // The tags property being a simple array of Tags objects works great because it isolates
        // the use of CoreData to the viewmodel; CoreData could be removed entirely and the view
        // wouldn't know any different. It's marked as @Published so whenever the array is changed
        // it notifies any observing views.
        @Published var tags = [Tag]()

        var tagFilters: [Filter] {
            tags.map { tag in
                Filter(id: tag.tagID, name: tag.tagName, icon: "tag", tag: tag)
            }
        }

        init(dc: DataController) {
            self.dc = dc
            let request = Tag.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(keyPath: \Tag.name, ascending: true)]

            tagsController = NSFetchedResultsController(
                fetchRequest: request,
                managedObjectContext: dc.container.viewContext,
                sectionNameKeyPath: nil,
                cacheName: nil
            )

            super.init()
            tagsController.delegate = self

            do {
                try tagsController.performFetch()
                tags = tagsController.fetchedObjects ?? []
            } catch {
                print("Failed to fetch tags")
            }
        }

        func controllerDidChangeContent(_ controller:
                                        NSFetchedResultsController<NSFetchRequestResult>) {
            if let newTags = controller.fetchedObjects as? [Tag] {
                tags = newTags
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

        func delete(_ filter: Filter) {
            guard let tag = filter.tag else { return }
            dc.delete(tag)
            dc.save()
        }

    }
}
