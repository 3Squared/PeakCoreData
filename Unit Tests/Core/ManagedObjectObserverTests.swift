//
//  ManagedObjectChangeObserverTests.swift
//  PeakCoreDataTests
//
//  Created by David Yates on 14/03/2018.
//  Copyright © 2018 3Squared Ltd. All rights reserved.
//

import XCTest
import CoreData

#if os(iOS)

@testable import PeakCoreData_iOS

#else

@testable import PeakCoreData_macOS

#endif

class ManagedObjectObserverTests: CoreDataTests {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testRefreshIsObserverFromObject() {
        let object = CoreDataTests.createTestEntityManagedObjects(in: viewContext, count: 1).first!
        try! viewContext.save()
        
        let expect = expectation(description: "")
        expect.expectedFulfillmentCount = 2

        let observer = object.observe { (obj, changeType) in
            switch changeType {
            case .initialised:
                expect.fulfill()
            case .refreshed:
                expect.fulfill()
            default:
                break
            }
        }
        
        viewContext.perform {
            self.viewContext.refreshAllObjects()
        }
        
        waitForExpectations(timeout: defaultTimeout)
    }
    
    func testRefreshFromObject() {
        let object = CoreDataTests.createTestEntityManagedObjects(in: viewContext, count: 1).first!
        try! viewContext.save()
        
        let expect = expectation(description: "")
        expect.expectedFulfillmentCount = 2

        let observer = ManagedObjectObserver(managedObject: object)
        observer.startObserving() { (obj, changeType) in
            switch changeType {
            case .initialised:
                expect.fulfill()
            case .refreshed:
                expect.fulfill()
            default:
                break
            }
        }
        
        viewContext.perform {
            self.viewContext.refreshAllObjects()
        }
        
        waitForExpectations(timeout: defaultTimeout)
    }
    
    func testUpdateIsObserverFromObject() {
        let object = CoreDataTests.createTestEntityManagedObjects(in: viewContext, count: 1).first!
        try! viewContext.save()
        
        let expect = expectation(description: "")
        expect.expectedFulfillmentCount = 2
        
        let observer = object.observe { (obj, changeType) in
            switch changeType {
            case .initialised:
                expect.fulfill()
            case .updated:
                XCTAssertEqual(obj.title, "testObserveFromID")
                XCTAssertEqual(Array(obj.changedValues().keys), ["title"])
                expect.fulfill()
            default:
                break
            }
        }
        
        viewContext.perform {
            object.title = "testObserveFromID"
        }
        
        waitForExpectations(timeout: defaultTimeout)
    }
    
    func testUpdateFromObject() {
        let object = CoreDataTests.createTestEntityManagedObjects(in: viewContext, count: 1).first!
        try! viewContext.save()
        
        let expect = expectation(description: "")
        expect.expectedFulfillmentCount = 2

        let observer = ManagedObjectObserver(managedObject: object)
        
        observer.startObserving() { (obj, changeType) in
            switch changeType {
            case .initialised:
                expect.fulfill()
            case .updated:
                XCTAssertEqual(obj.title, "testObserveFromID")
                XCTAssertEqual(Array(obj.changedValues().keys), ["title"])
                expect.fulfill()
            default:
                break
            }
        }
        
        viewContext.perform {
            object.title = "testObserveFromID"
        }
        
        waitForExpectations(timeout: defaultTimeout)
    }
    
    func testUpdateIsObserverFromObjectID() {
        let object = CoreDataTests.createTestEntityManagedObjects(in: viewContext, count: 1).first!
        try! viewContext.save()
        
        let expect = expectation(description: "")
        expect.expectedFulfillmentCount = 2

        let observer = object.objectID.observe(in: viewContext) { (obj: TestEntity, changeType) in
            switch changeType {
            case .initialised:
                expect.fulfill()
            case .updated:
                XCTAssertEqual(obj.title, "testObserveFromID")
                XCTAssertEqual(Array(obj.changedValues().keys), ["title"])
                expect.fulfill()
            default:
                break
            }
        }
        
        viewContext.perform {
            object.title = "testObserveFromID"
        }
        
        waitForExpectations(timeout: defaultTimeout)
    }
    
    func testUpdateFromObjectID() {
        let object = CoreDataTests.createTestEntityManagedObjects(in: viewContext, count: 1).first!
        try! viewContext.save()
        
        let expect = expectation(description: "")
        expect.expectedFulfillmentCount = 2
        
        let observer: ManagedObjectObserver<TestEntity> = ManagedObjectObserver(managedObjectID: object.objectID, context: viewContext)
        observer.startObserving() { (obj, changeType) in
            switch changeType {
            case .initialised:
                expect.fulfill()
            case .updated:
                XCTAssertEqual(obj.title, "testObserveFromID")
                XCTAssertEqual(Array(obj.changedValues().keys), ["title"])
                expect.fulfill()
            default:
                break
            }
        }
        
        viewContext.perform {
            object.title = "testObserveFromID"
        }
        
        waitForExpectations(timeout: defaultTimeout)
    }
    
    func testDeleteIsObserverFromObject() {
        let object = CoreDataTests.createTestEntityManagedObjects(in: viewContext, count: 1).first!
        try! viewContext.save()
        
        let expect = expectation(description: "")
        expect.expectedFulfillmentCount = 2

        let observer = object.observe { (obj, changeType) in
            switch changeType {
            case .initialised:
                expect.fulfill()
            case .deleted:
                XCTAssertTrue(obj.isDeleted)
                expect.fulfill()
            default:
                break
            }
        }
        
        viewContext.perform {
            self.viewContext.delete(object)
        }
        
        waitForExpectations(timeout: defaultTimeout)
    }
    
    func testDeleteFromObject() {
        let object = CoreDataTests.createTestEntityManagedObjects(in: viewContext, count: 1).first!
        try! viewContext.save()
        
        let expect = expectation(description: "")
        expect.expectedFulfillmentCount = 2

        let observer = ManagedObjectObserver(managedObject: object)
        observer.startObserving() { (obj, changeType) in
            switch changeType {
            case .initialised:
                expect.fulfill()
            case .deleted:
                XCTAssertTrue(obj.isDeleted)
                expect.fulfill()
            default:
                break
            }
        }
        
        viewContext.perform {
            self.viewContext.delete(object)
        }
        
        waitForExpectations(timeout: defaultTimeout)
    }
    
    func testDeleteIsObserverFromObjectID() {
        let object = CoreDataTests.createTestEntityManagedObjects(in: viewContext, count: 1).first!
        try! viewContext.save()
        
        let expect = expectation(description: "")
        expect.expectedFulfillmentCount = 2

        let observer = object.objectID.observe(in: viewContext) { (obj: TestEntity, changeType) in
            switch changeType {
            case .initialised:
                expect.fulfill()
            case .deleted:
                XCTAssertTrue(obj.isDeleted)
                expect.fulfill()
            default:
                break
            }
        }
        
        viewContext.perform {
            self.viewContext.delete(object)
        }
        
        waitForExpectations(timeout: defaultTimeout)
    }
    
    func testDeleteFromObjectID() {
        let object = CoreDataTests.createTestEntityManagedObjects(in: viewContext, count: 1).first!
        try! viewContext.save()
        
        let expect = expectation(description: "")
        expect.expectedFulfillmentCount = 2

        let observer: ManagedObjectObserver<TestEntity> = ManagedObjectObserver(managedObjectID: object.objectID, context: viewContext)
        observer.startObserving() { (obj, changeType) in
            switch changeType {
            case .initialised:
                expect.fulfill()
            case .deleted:
                XCTAssertTrue(obj.isDeleted)
                expect.fulfill()
            default:
                break
            }
        }
        
        viewContext.perform {
            self.viewContext.delete(object)
        }
        
        waitForExpectations(timeout: defaultTimeout)
    }
    
    func testObjectIsFoundInDifferentContext() {
        let object = CoreDataTests.createTestEntityManagedObjects(in: viewContext, count: 1).first!
        try! viewContext.save()
        
        let observer = object.observe(in: persistentContainer.newBackgroundContext()) { _, _ in  }
        
        XCTAssertNotEqual(observer.object, object)
        XCTAssertNotEqual(observer.object.managedObjectContext, object.managedObjectContext)
        XCTAssertEqual(observer.object.objectID, object.objectID)
    }
}
