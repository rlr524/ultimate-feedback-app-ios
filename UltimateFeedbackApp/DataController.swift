//
//  DataController.swift
//  UltimateFeedbackApp
//
//  Created by Rob Ranf on 5/20/23.
//

import CoreData

// Make the DC an observable object so any SwiftUI view can create an instance
// and watch it as needed. The NSPersistentCloudKitContainer instance loads and
// manages local data using CoreData and also synchronizes that data with
// the user's iCloud account so all user devices share the same app data.
class DataController : ObservableObject {
    let container: NSPersistentCloudKitContainer
    @Published var selectedFilter: Filter? = Filter.all
    @Published var selectedIssue: Issue?
    
    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "Main")
        
        // Allow data to be created in-mem; it will disappear when app
        // closes, but it helps for testing and for previews.
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(filePath: "/dev/null")
        }
        
        // Automatically apply to the view context any changes that happen in
        // the underlying persistent store, so the two stay in sync.
        container.viewContext.automaticallyMergesChangesFromParent = true
        
        // Tell Core Data how to handle merging local and remote data. In this case,
        // Core Data should compare each property individually and if there
        // is a conflict, prefer what is currently in memory.
        container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        
        // Tell Core Data we want to be notified when the store has changed and tell
        // the system to call the remoteStoreChanged() method when a change happens.
        container.persistentStoreDescriptions.first?.setOption(true as NSNumber,
                                                               forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        NotificationCenter.default.addObserver(forName: .NSPersistentStoreRemoteChange,
                                               object: container.persistentStoreCoordinator,
                                               queue: .main, using: remoteStoreChanged)
        
        // If in-mem is false, load the underlying DB onto disk or bail out if there's a failure.
        container.loadPersistentStores { storeDescription, error in
            if let error {
                fatalError("Fatal error loading store: \(error.localizedDescription)")
            }
            print(storeDescription)
        }
    }
    
    func createSampleData() {
        // viewContext is effectively a pool of data that has been loaded from disk or in-mem.
        let viewContext = container.viewContext
        
        for i in 1...5 {
            let tag = Tag(context: viewContext)
            tag.id = UUID()
            tag.name = "Tag \(i)"
            
            for j in 1...10 {
                let issue = Issue(context: viewContext)
                issue.title = "Issue \(i)-\(j)"
                issue.content = "Issue description goes here"
                issue.creationDate = .now
                issue.completed = Bool.random()
                issue.priority = Int16.random(in: 0...2)
                tag.addToIssues(issue)
            }
        }
        
        // Attempt to write all the new objects to persistent storage.
        try? viewContext.save()
    }
    
    static var preview: DataController = {
        let dataController = DataController(inMemory: true)
        dataController.createSampleData()
        return dataController
    }()
    
    func save() {
        if container.viewContext.hasChanges {
            try? container.viewContext.save()
        }
    }
    
    func delete(_ object: NSManagedObject) {
        objectWillChange.send()
        container.viewContext.delete(object)
        save()
    }
    
    private func delete(_ fetchRequest: NSFetchRequest<NSFetchRequestResult>) {
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        batchDeleteRequest.resultType = .resultTypeObjectIDs
        
        if let delete = try? container.viewContext.execute(batchDeleteRequest) as?
            NSBatchDeleteResult {
            let changes = [NSDeletedObjectsKey: delete.result as? [NSManagedObjectID] ?? []]
            NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes,
                                                into: [container.viewContext])
        }
    }
    
    func deleteAll() {
        let request1: NSFetchRequest<NSFetchRequestResult> = Tag.fetchRequest()
        delete(request1)
        
        let request2: NSFetchRequest<NSFetchRequestResult> = Issue.fetchRequest()
        delete(request2)
        
        save()
    }
    
    func remoteStoreChanged(_ notification: Notification) {
        objectWillChange.send()
    }
    
    /**
     There is one complicated part of IssueView, which is how we handle tags: we need a way
     to let the user select multiple tags, which is tricky because SwiftUI’s built-in Picker view
     only supports single selection. This means we need to roll something ourselves, ideally in
     a way that makes it easy for users to see all their tags up front, and also to add or remove
     a tag quickly.

     With a little trial and error, the solution I found worked best was to use a Menu view with 
     items for all the selected and unselected tags. We can already read the selected tags because
     of the issueTags property we made earlier, but to get the unselected tags we need to add a
     little code to DataController that will perform a symmetric difference of our issue’s tags
     and all tags. That’s a fancy way of saying “tell me all issues that aren’t already assigned
     to this tag,” and it’s one the built-in set operations Swift has.

     Let’s put this into code. We need a method that will:

     - Accept an issue and return an array of all the tags it’s missing.
     - Internally load all the tags that can exist.
     - Compute which tags aren’t currently assigned to the issue.
     - Sort those tags, then send them back.
     */
    func missingTags(from issue: Issue) -> [Tag] {
        let request = Tag.fetchRequest()
        let allTags = (try? container.viewContext.fetch(request)) ?? []
        
        let allTagsSet = Set(allTags)
        let difference = allTagsSet.symmetricDifference(issue.issueTags)
        
        return difference.sorted()
    }
}
