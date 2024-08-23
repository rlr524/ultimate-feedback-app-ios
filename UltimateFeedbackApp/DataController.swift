//
//  DataController.swift
//  UltimateFeedbackApp
//
//  Created by Rob Ranf on 5/20/23.
//

import CoreData

enum SortType: String {
    case dateCreated = "creationDate"
    case dateModified = "modificationDate"
}

enum Status {
    case all, open, closed
}

// Make the DC an observable object so any SwiftUI view can create an instance
// and watch it as needed. The NSPersistentCloudKitContainer instance loads and
// manages local data using CoreData and also synchronizes that data with
// the user's iCloud account so all user devices share the same app data.
class DataController : ObservableObject {
    let container: NSPersistentCloudKitContainer
    @Published var selectedFilter: Filter? = Filter.all
    @Published var selectedIssue: Issue?
    @Published var filterText = ""
    @Published var filterTokens = [Tag]()
    @Published var filterEnabled = false
    @Published var filterPriority = -1
    @Published var filterStatus = Status.all
    @Published var sortType = SortType.dateCreated
    @Published var sortNewestFirst = true
    
    // This won’t return a value because it’s just calling our save() method, but it might throw an
    // error because before calling save() we’ll ask the task to sleep for a while. So, we need to
    // declare this as a Task<Void, Error> to match our needs, and we’ll also make it optional
    // because it won’t exist at first.
    private var saveTask: Task<Void, Error>?
    
    var suggestedFilterTokens: [Tag] {
        guard filterText.starts(with: "#") else {
            return []
        }
        
        let trimmedFilterText = String(filterText.dropFirst()).trimmingCharacters(in: .whitespaces)
        let request = Tag.fetchRequest()
        
        if trimmedFilterText.isEmpty == false {
            request.predicate = NSPredicate(format: "name CONTAINS[c] %@", trimmedFilterText)
        }
        
        return (try? container.viewContext.fetch(request).sorted()) ?? []
    }
    
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
    
    /** We need to add a method that will save our changes after a delay. This can be done
     by creating a new task, making it sleep for a few seconds, then calling save(). Note we
     cancel the task first if another change comes in, making sure that any existing queued
     save doesn’t happen.
     
     @MainActor tells the task it needs to run its body on the main actor (the main thread),
     which matters. You see, although Core Data is designed to work well in a multi-threaded
     environment, it’s something you really need to handle carefully – it’s a really bad idea
     to pass one managed object between threads, for example, which is exactly the kind of thing
     that Task makes easy to do by accident.
     
     So, until I have a reason to do otherwise – i.e., if I need to implement some slow-running
     task such as mass-creating data – I prefer to keep all my Core Data work on the main actor.
     Everything we’ve done elsewhere is already there because it’s triggered by SwiftUI, but this
     task does need to be explicit.
     */
    func queueSave() {
        saveTask?.cancel()
        
        saveTask = Task { @MainActor in
            try await Task.sleep(for: .seconds(3))
            save()
        }
    }
    
    func issuesForSelectedFilter() -> [Issue] {
        let filter = selectedFilter ?? .all
        var predicates = [NSPredicate]()
        
        // The predicate "tags CONTAINS %@" means "the tags relationship for the issue in question
        // must contain a particular tag", in this case that's the currently selected tag.
        if let tag = filter.tag {
            let tagPredicate = NSPredicate(format: "tags CONTAINS %@", tag)
            predicates.append(tagPredicate)
        } else {
            // modificationDate is greater than the earliest (min) modification date
            let datePredicate = NSPredicate(format: "modificationDate > %@",
                                            filter.minModificationDate as NSDate)
            predicates.append(datePredicate)
        }
        
        let trimmedFilterText = filterText.trimmingCharacters(in: .whitespaces)
        
        // CONTAINS[c] does a case-insensitive comparison
        if trimmedFilterText.isEmpty == false {
            let titlePredicate = NSPredicate(format: "title CONTAINS[c] %@", trimmedFilterText)
            let contentPredicate = NSPredicate(format: "content CONTAINS[c] %@", trimmedFilterText)
            let combinedPredicate =
            NSCompoundPredicate(orPredicateWithSubpredicates: [titlePredicate, contentPredicate])
            predicates.append(combinedPredicate)
        }
        
        if filterTokens.isEmpty == false {
            for filterToken in filterTokens {
                let tokenPredicate = NSPredicate(format: "tags CONTAINS %@", filterToken)
                predicates.append(tokenPredicate)
            }
            
        }
        
        if filterEnabled {
            if filterPriority >= 0 {
                // %d is the same as a format specifier in Java, it refers to a
                // placeholder that will be filled by an integer (NSPredicate uses C-style specifiers)
                let priorityFilter = NSPredicate(format: "priority = %d", filterPriority)
                predicates.append(priorityFilter)
            }
            
            if filterStatus != .all {
                let lookForClosed = filterStatus == .closed
                let statusFilter = NSPredicate(format: "completed = %@", NSNumber(value: lookForClosed))
                predicates.append(statusFilter)
            }
        }
        
        let request = Issue.fetchRequest()
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        request.sortDescriptors = [NSSortDescriptor(key: sortType.rawValue, ascending: sortNewestFirst)]
        
        let allIssues = (try? container.viewContext.fetch(request)) ?? []
        return allIssues.sorted()
    }
    
    func newIssue() {
        let issue = Issue(context: container.viewContext)
        issue.title = "New Issue"
        issue.creationDate = .now
        issue.priority = 1
        if let tag = selectedFilter?.tag {
            issue.addToTags(tag)
        }
        save()
        selectedIssue = issue
    }
    
    func newTag() {
        let tag = Tag(context: container.viewContext)
        tag.id = UUID()
        tag.name = "New tag"
        save()
    }
    
    func count<T>(for fetchRequest: NSFetchRequest<T>) -> Int {
        (try? container.viewContext.count(for: fetchRequest)) ?? 0
    }
    
    func hasEarned(award: Award) -> Bool {
        switch award.criteria {
        case "issues":
            // returns true if they added a certain number of issues
            let fetchRequest = Issue.fetchRequest()
            let awardCount = count(for: fetchRequest)
            return awardCount >= award.value
            
        case "closed":
            // returns true if they closed a certain number of issues
            let fetchRequest = Issue.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "completed = true")
            let awardCount = count(for: fetchRequest)
            return awardCount >= award.value
            
        case "tags":
            // returns true if they created a certain number of tags
            let fetchRequest = Tag.fetchRequest()
            let awardCount = count(for: fetchRequest)
            return awardCount >= award.value
            
        default:
            // an unknown award criteria; this should never be allowed
            //fatalError("Unknown award criteria: \(award.criteria)")
            return false
        }
    }
}
