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
        let object = CoreDataTests.createTestManagedObjects(inContext: mainContext, count: 1).first!
        try! mainContext.save()
        
        let expect = expectation(description: "")

        let observer: FetchedObjectObserver<TestEntity> = object.objectID.observe(in: mainContext) { object in
            XCTAssertEqual(object!.title, "testObserveFromID")
            expect.fulfill()
        }
        
        mainContext.perform {
            object.title = "testObserveFromID"
            try! self.mainContext.save()
        }

        waitForExpectations(timeout: defaultTimeout)
        observer.cleanUp()
    }
    
    func testEditIsObservedFromObject() {
        let object = CoreDataTests.createTestManagedObjects(inContext: mainContext, count: 1).first!
        try! mainContext.save()
        
        let expect = expectation(description: "")
        
        let observer: FetchedObjectObserver<TestEntity> = object.observe(in: mainContext) { object in
            XCTAssertEqual(object!.title, "testObserveFromID")
            expect.fulfill()
        }
        
        mainContext.perform {
            object.title = "testObserveFromID"
            try! self.mainContext.save()
        }
        
        waitForExpectations(timeout: defaultTimeout)
        observer.cleanUp()
    }
    
    
    func testDeletionIsObservedFromObject() {
        let object = CoreDataTests.createTestManagedObjects(inContext: mainContext, count: 1).first!
        try! mainContext.save()
        
        let expect = expectation(description: "")
        
        let observer = object.observe(in: mainContext) { changedObject in
            XCTAssertNil(changedObject)
            expect.fulfill()
        }
        
        mainContext.perform {
            self.mainContext.delete(object)
        }
        
        waitForExpectations(timeout: defaultTimeout)
        observer.cleanUp()
    }
    
    func testObjectIsEqual() {
        let object = CoreDataTests.createTestManagedObjects(inContext: mainContext, count: 1).first!
        try! mainContext.save()
        let observer = object.observe { _ in  }
        XCTAssertEqual(observer.object!, object)
        observer.cleanUp()
    }

    
    func testObjectIsFoundInDifferentContext() {
        let object = CoreDataTests.createTestManagedObjects(inContext: mainContext, count: 1).first!
        try! mainContext.save()
        let observer = object.observe(in: persistentContainer.newBackgroundContext()) { _ in  }
        
        XCTAssertNotEqual(observer.object!, object)
        XCTAssertNotEqual(observer.object!.managedObjectContext, object.managedObjectContext)
        XCTAssertEqual(observer.object!.objectID, object.objectID)
        observer.cleanUp()
    }


}
