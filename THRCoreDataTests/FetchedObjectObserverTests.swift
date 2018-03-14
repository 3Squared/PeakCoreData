//
//  FetchedObjectTests.swift
//  THRCoreDataTests
//
//  Created by Sam Oakley on 22/02/2018.
//  Copyright © 2018 3Squared Ltd. All rights reserved.
//

import XCTest
import CoreData
@testable import THRCoreData

class FetchedObjectObserverTests: CoreDataTests {
    
    func testEditIsObservedFromID() {
        let object = CoreDataTests.createTestManagedObjects(in: viewContext, count: 1).first!
        try! viewContext.save()
        
        let expect = expectation(description: "")

        let observer: FetchedObjectObserver<TestEntity> = object.objectID.observe(in: viewContext) { object in
            XCTAssertEqual(object!.title, "testObserveFromID")
            expect.fulfill()
        }
        
        viewContext.perform {
            object.title = "testObserveFromID"
            try! self.viewContext.save()
        }

        waitForExpectations(timeout: defaultTimeout)
    }
    
    func testEditIsObservedFromObject() {
        let object = CoreDataTests.createTestManagedObjects(in: viewContext, count: 1).first!
        try! viewContext.save()
        
        let expect = expectation(description: "")
        
        let observer: FetchedObjectObserver<TestEntity> = object.observe(in: viewContext) { object in
            XCTAssertEqual(object!.title, "testObserveFromID")
            expect.fulfill()
        }
        
        viewContext.perform {
            object.title = "testObserveFromID"
            try! self.viewContext.save()
        }
        
        waitForExpectations(timeout: defaultTimeout)
    }
    
    
    func testDeletionIsObservedFromObject() {
        let object = CoreDataTests.createTestManagedObjects(in: viewContext, count: 1).first!
        try! viewContext.save()
        
        let expect = expectation(description: "")
        
        let observer = object.observe(in: viewContext) { changedObject in
            XCTAssertNil(changedObject)
            expect.fulfill()
        }
        
        viewContext.perform {
            self.viewContext.delete(object)
        }
        
        waitForExpectations(timeout: defaultTimeout)
    }
    
    func testObjectIsEqual() {
        let object = CoreDataTests.createTestManagedObjects(in: viewContext, count: 1).first!
        try! viewContext.save()
        let observer = object.observe { _ in  }
        XCTAssertEqual(observer.object!, object)
    }

    
    func testObjectIsFoundInDifferentContext() {
        let object = CoreDataTests.createTestManagedObjects(in: viewContext, count: 1).first!
        try! viewContext.save()
        let observer = object.observe(in: persistentContainer.newBackgroundContext()) { _ in  }
        
        XCTAssertNotEqual(observer.object!, object)
        XCTAssertNotEqual(observer.object!.managedObjectContext, object.managedObjectContext)
        XCTAssertEqual(observer.object!.objectID, object.objectID)
    }


}
