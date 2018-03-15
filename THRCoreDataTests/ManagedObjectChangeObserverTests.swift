//
//  ManagedObjectChangeObserverTests.swift
//  THRCoreDataTests
//
//  Created by David Yates on 14/03/2018.
//  Copyright © 2018 3Squared Ltd. All rights reserved.
//

import XCTest
import CoreData
@testable import THRCoreData

class ManagedObjectChangeObserverTests: CoreDataTests {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testRefreshIsObserverFromObject() {
        let object = CoreDataTests.createTestManagedObjects(in: viewContext, count: 1).first!
        try! viewContext.save()
        
        let expect = expectation(description: "")
        
        object.observe { (obj, changeType) in
            XCTAssertEqual(changeType, .refreshed)
            expect.fulfill()
        }
        
        viewContext.perform {
            self.viewContext.refreshAllObjects()
        }
        
        waitForExpectations(timeout: defaultTimeout)
    }
    
    func testRefreshFromObject() {
        let object = CoreDataTests.createTestManagedObjects(in: viewContext, count: 1).first!
        try! viewContext.save()
        
        let expect = expectation(description: "")
        
        let _ = ManagedObjectChangeObserver(with: object) { (obj, changeType) in
            XCTAssertEqual(changeType, .refreshed)
            expect.fulfill()
        }
        
        viewContext.perform {
            self.viewContext.refreshAllObjects()
        }
        
        waitForExpectations(timeout: defaultTimeout)
    }
    
    func testUpdateIsObserverFromObject() {
        let object = CoreDataTests.createTestManagedObjects(in: viewContext, count: 1).first!
        try! viewContext.save()
        
        let expect = expectation(description: "")

        object.observe { (obj, changeType) in
            XCTAssertEqual(obj.title, "testObserveFromID")
            XCTAssertEqual(Array(obj.changedValues().keys), ["title"])
            XCTAssertEqual(changeType, .updated)
            expect.fulfill()
        }
        
        viewContext.perform {
            object.title = "testObserveFromID"
        }
        
        waitForExpectations(timeout: defaultTimeout)
    }
    
    func testUpdateFromObject() {
        let object = CoreDataTests.createTestManagedObjects(in: viewContext, count: 1).first!
        try! viewContext.save()
        
        let expect = expectation(description: "")
        
        let _ = ManagedObjectChangeObserver(with: object) { (obj, changeType) in
            XCTAssertEqual(obj.title, "testObserveFromID")
            XCTAssertEqual(Array(obj.changedValues().keys), ["title"])
            XCTAssertEqual(changeType, .updated)
            expect.fulfill()
        }
        
        viewContext.perform {
            object.title = "testObserveFromID"
        }
        
        waitForExpectations(timeout: defaultTimeout)
    }
    
    func testUpdateIsObserverFromObjectID() {
        let object = CoreDataTests.createTestManagedObjects(in: viewContext, count: 1).first!
        try! viewContext.save()
        
        let expect = expectation(description: "")
        object.objectID.observe(in: viewContext) { (obj: TestEntity, changeType) in
            XCTAssertEqual(obj.title, "testObserveFromID")
            XCTAssertEqual(Array(obj.changedValues().keys), ["title"])
            XCTAssertEqual(changeType, .updated)
            expect.fulfill()
        }
        
        viewContext.perform {
            object.title = "testObserveFromID"
        }
        
        waitForExpectations(timeout: defaultTimeout)
    }
    
    func testUpdateFromObjectID() {
        let object = CoreDataTests.createTestManagedObjects(in: viewContext, count: 1).first!
        try! viewContext.save()
        
        let expect = expectation(description: "")
        
        let _ = ManagedObjectChangeObserver(with: object.objectID, in: viewContext) { (obj: TestEntity, changeType) in
            XCTAssertEqual(obj.title, "testObserveFromID")
            XCTAssertEqual(Array(obj.changedValues().keys), ["title"])
            XCTAssertEqual(changeType, .updated)
            expect.fulfill()
        }
        
        viewContext.perform {
            object.title = "testObserveFromID"
        }
        
        waitForExpectations(timeout: defaultTimeout)
    }
    
    func testDeleteIsObserverFromObject() {
        let object = CoreDataTests.createTestManagedObjects(in: viewContext, count: 1).first!
        try! viewContext.save()
        
        let expect = expectation(description: "")
        
        object.observe { (obj, changeType) in
            XCTAssertTrue(obj.isDeleted)
            XCTAssertEqual(changeType, .deleted)
            expect.fulfill()
        }
        
        viewContext.perform {
            self.viewContext.delete(object)
        }
        
        waitForExpectations(timeout: defaultTimeout)
    }
    
    func testDeleteFromObject() {
        let object = CoreDataTests.createTestManagedObjects(in: viewContext, count: 1).first!
        try! viewContext.save()
        
        let expect = expectation(description: "")
        
        let _ = ManagedObjectChangeObserver(with: object) { (obj, changeType) in
            XCTAssertTrue(obj.isDeleted)
            XCTAssertEqual(changeType, .deleted)
            expect.fulfill()
        }
        
        viewContext.perform {
            self.viewContext.delete(object)
        }
        
        waitForExpectations(timeout: defaultTimeout)
    }
    
    func testDeleteIsObserverFromObjectID() {
        let object = CoreDataTests.createTestManagedObjects(in: viewContext, count: 1).first!
        try! viewContext.save()
        
        let expect = expectation(description: "")
        object.objectID.observe(in: viewContext) { (obj: TestEntity, changeType) in
            XCTAssertTrue(obj.isDeleted)
            XCTAssertEqual(changeType, .deleted)
            expect.fulfill()
        }
        
        viewContext.perform {
            self.viewContext.delete(object)
        }
        
        waitForExpectations(timeout: defaultTimeout)
    }
    
    func testDeleteFromObjectID() {
        let object = CoreDataTests.createTestManagedObjects(in: viewContext, count: 1).first!
        try! viewContext.save()
        
        let expect = expectation(description: "")
        
        let _ = ManagedObjectChangeObserver(with: object.objectID, in: viewContext) { (obj: TestEntity, changeType) in
            XCTAssertTrue(obj.isDeleted)
            XCTAssertEqual(changeType, .deleted)
            expect.fulfill()
        }
        
        viewContext.perform {
            self.viewContext.delete(object)
        }
        
        waitForExpectations(timeout: defaultTimeout)
    }
    
    func testObjectIsFoundInDifferentContext() {
        let object = CoreDataTests.createTestManagedObjects(in: viewContext, count: 1).first!
        try! viewContext.save()
        
        let observer = object.observe(in: persistentContainer.newBackgroundContext()) { _, _ in  }
        
        XCTAssertNotEqual(observer.object, object)
        XCTAssertNotEqual(observer.object.managedObjectContext, object.managedObjectContext)
        XCTAssertEqual(observer.object.objectID, object.objectID)
    }
}
