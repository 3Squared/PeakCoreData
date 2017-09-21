//
//  TestStack.swift
//  THRCoreData
//
//  Created by David Yates on 12/12/2016.
//  Copyright © 2016 3Squared Ltd. All rights reserved.
//

import XCTest
import CoreData
@testable import THRCoreData

class StackTests: CoreDataTests {
    
    func testMainContext() {
        XCTAssertNotNil(mainContext, "Main context should never be nil")
        XCTAssertEqual(mainContext.concurrencyType, .mainQueueConcurrencyType, "Main context should have main queue concurrency type")
    }
    
    func testSingleStore() {
        XCTAssertTrue(mainContext.persistentStoreCoordinator!.persistentStores.count == 1, "Should only be 1 persistent store")
    }
}
