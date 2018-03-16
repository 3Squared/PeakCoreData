//
//  FetchedCountTests.swift
//  THRCoreDataTests
//
//  Created by David Yates on 16/03/2018.
//  Copyright © 2018 3Squared Ltd. All rights reserved.
//

import XCTest
import CoreData
@testable import THRCoreData

class FetchedCountTests: CoreDataTests {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testFetchedCountOnChangeBlock() {
        let expect = expectation(description: "")
        
        let fetchedCount = FetchedCount(fetchRequest: TestEntity.sortedFetchRequest(), managedObjectContext: viewContext)
        fetchedCount.onChange = { count in
            XCTAssertEqual(count, 10000)
            expect.fulfill()
        }
        
        CoreDataTests.createTestManagedObjects(in: viewContext, count: 10000)
        try! viewContext.save()
        
        waitForExpectations(timeout: defaultTimeout)
    }
    
    func testFetchedCountCount() {
        let fetchedCount = FetchedCount(fetchRequest: TestEntity.sortedFetchRequest(), managedObjectContext: viewContext)
        XCTAssertEqual(fetchedCount.count, 0)
        
        CoreDataTests.createTestManagedObjects(in: viewContext, count: 10000)
        try! viewContext.save()
        
        XCTAssertEqual(fetchedCount.count, 10000)
    }
}
