//
//  UltimateFeedbackAppTests.swift
//  UltimateFeedbackAppTests
//
//  Created by Rob Ranf on 12/9/24.
//

import CoreData
@testable import UltimateFeedbackApp
import XCTest

class BaseTestCase: XCTestCase {
    var dc: DataController!
    var moc: NSManagedObjectContext!

    override func setUpWithError() throws {
        dc = DataController(inMemory: true)
        moc = dc.container.viewContext
    }
}
