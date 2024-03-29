//
//  ManagedObjectContextTests.swift
//  PeakCoreDataTests
//
//  Created by David Yates on 28/03/2019.
//  Copyright © 2019 3Squared Ltd. All rights reserved.
//

import XCTest
import CoreData
@testable import PeakCoreData

class ManagedObjectContextTests: CoreDataTests {

    func testPerformAndWait() {
        let insertCount = 100
        createTestEntityStringObjects(count: insertCount)
        let count = viewContext.performAndWait {
            return TestEntityString.count(in: viewContext)
        }
        XCTAssertEqual(insertCount, count)
    }
    
    func testPerformAndWaitThrows() {
        let insertCount = 100
        createTestEntityStringObjects(count: insertCount)
        let count: Int
        do {
            count = try viewContext.performAndWait {
                try viewContext.count(for: TestEntityString.sortedFetchRequest())
            }
        } catch {
            count = 0
        }
        XCTAssertEqual(insertCount, count)
    }
}
