//
//  ContextObserverTests.swift
//  THRCoreDataTests
//
//  Created by David Yates on 14/03/2018.
//  Copyright © 2018 3Squared Ltd. All rights reserved.
//

import XCTest
import CoreData
@testable import THRCoreData

class ContextObserverTests: CoreDataTests {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testUpdate() {
        let object = CoreDataTests.createTestManagedObjects(in: viewContext, count: 1).first!
        try! viewContext.save()
        
        let expect = expectation(description: "")
        
        let observer = CoreDataContextObserver<TestEntity>(context: viewContext)
        observer.observeObject(object: object, state: .updated, completionBlock: { updatedObject, state in
            XCTAssertEqual(updatedObject.title, "testObserveFromID")
            XCTAssertEqual(state, .updated)
            expect.fulfill()
        })
        
        viewContext.perform {
            object.title = "testObserveFromID"
        }
        
        waitForExpectations(timeout: defaultTimeout)
    }
    
    func testDeletion() {
        let object = CoreDataTests.createTestManagedObjects(in: viewContext, count: 1).first!
        try! viewContext.save()
        
        let expect = expectation(description: "")
        
        let observer = CoreDataContextObserver<TestEntity>(context: viewContext)
        observer.observeObject(object: object, state: .deleted, completionBlock: { updatedObject, state in
            XCTAssertTrue(updatedObject.isDeleted)
            XCTAssertEqual(state, .deleted)
            expect.fulfill()
        })
        
        viewContext.perform {
            self.viewContext.delete(object)
        }
        
        waitForExpectations(timeout: defaultTimeout)
    }
    
    func testInsertion() {
        let expect = expectation(description: "")
        
        let observer = CoreDataContextObserver<TestEntity>(context: viewContext)
        observer.contextChangeBlock = { notification, changes in
            guard let firstChange = changes.first else { return }
            switch firstChange {
            case .inserted(_):
                expect.fulfill()
            default:
                XCTFail()
            }
        }
        
        viewContext.perform {
            TestEntity.insertObject(in: self.viewContext)
        }
        
        waitForExpectations(timeout: defaultTimeout)
    }
    
}
