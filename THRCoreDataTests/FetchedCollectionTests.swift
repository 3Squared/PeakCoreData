//
//  FetchedCollectionTests.swift
//  THRCoreDataTests
//
//  Created by Sam Oakley on 19/01/2018.
//  Copyright © 2018 3Squared Ltd. All rights reserved.
//

import XCTest
import CoreData
import THRResult
@testable import THRCoreData

class FetchedCollectionTests: CoreDataTests {
    
    func testSnapshotIsStatic() {
        CoreDataTests.createTestManagedObjects(inContext: mainContext, count: 10)
        try! mainContext.save()
        
        let expect = expectation(description: "")
        let results = allThings { _, update in
            if update != nil { expect.fulfill() }
        }

        let snap = results.snapshot()
        
        XCTAssertEqual(results.count, 10)
        XCTAssertEqual(snap.count, 10)
        
        mainContext.performAndWait {
            self.mainContext.delete(results[(0, 0)])
        }
        
        waitForExpectations(timeout: defaultTimeout)
        
        XCTAssertEqual(results.count, 9)
        XCTAssertEqual(snap.count, 10)
    }
        
    func testSectionedResults() {
        CoreDataTests.createTestManagedObjects(inContext: mainContext, count: 10)
        try! mainContext.save()
        
        let results = sectionedThings() { _, _ in }
        XCTAssertEqual(results.sections.count, 10)
        
        results.sections.forEach { section in
            XCTAssertEqual(section.numberOfObjects, 1)
        }
        
        results.cleanUp()
    }
    
    func testInsertChanges() {
        let expect = expectation(description: "")
        
        let results = allThings() { result, changes in
            if changes == nil {
                return
            }
            let objects = try! result.resolve()
            XCTAssertEqual(objects.count, 10)
            
            changes!.forEach { update in
                switch update {
                case .insert(at: _):
                    break
                default:
                    XCTFail()
                }
            }
            
            expect.fulfill()
        }
        
        mainContext.perform {
            CoreDataTests.createTestManagedObjects(inContext: self.mainContext, count: 10)
            try! self.mainContext.save()
        }
        
        waitForExpectations(timeout: defaultTimeout)
        results.cleanUp()
    }
    
    func testInsertSectionChanges() {
        CoreDataTests.createTestManagedObjects(inContext: mainContext, count: 1)
        try! mainContext.save()
        
        let results = sectionedThings() { _, _ in }
        XCTAssertEqual(results.sections.count, 1)
        
        mainContext.performAndWait {
            CoreDataTests.createTestManagedObjects(inContext: self.mainContext, count: 1)
            try! self.mainContext.save()
        }

        XCTAssertEqual(results.sections.count, 2)

        results.sections.forEach { section in
            XCTAssertEqual(section.numberOfObjects, 1)
        }
        
        results.cleanUp()
    }

    
    func testDeletionChanges() {
        let expect = expectation(description: "")
        let inserted = CoreDataTests.createTestManagedObjects(inContext: self.mainContext, count: 10)
        mainContext.perform {
            try! self.mainContext.save()
        }
        
        let results = allThings() { result, changes in
            let objects = try! result.resolve()
            if changes == nil {
                XCTAssertEqual(objects.count, 10)
                return
            }
            
            XCTAssertEqual(objects.count, 9)
            XCTAssertEqual(changes!.count, 1)
            
            switch changes![0] {
            case .delete(at: _):
                break
            default:
                XCTFail()
            }
            
            expect.fulfill()
        }
        
        let thing = inserted[0]
        mainContext.perform {
            self.mainContext.delete(thing)
            try! self.mainContext.save()
        }
        
        
        waitForExpectations(timeout: defaultTimeout)
        results.cleanUp()
    }
    
    
    func testUpdateChanges() {
        let expect = expectation(description: "")
        let inserted = CoreDataTests.createTestManagedObjects(inContext: self.mainContext, count: 10)
        mainContext.perform {
            try! self.mainContext.save()
        }
        
        let results = allThings() { result, changes in
            let objects = try! result.resolve()
            if changes == nil {
                XCTAssertEqual(objects.count, 10)
                return
            }
            
            XCTAssertEqual(objects.count, 10)
            XCTAssertEqual(changes!.count, 1)
            
            switch changes![0] {
            case .update(at: _, with: let object):
                XCTAssertEqual(object.uniqueID!, "what")
                break
            default:
                XCTFail()
            }
            
            expect.fulfill()
        }
        
        let thing = inserted[0]
        mainContext.perform {
            thing.uniqueID = "what"
            try! self.mainContext.save()
        }
        
        waitForExpectations(timeout: defaultTimeout)
        results.cleanUp()
    }
    
    func testMoveChanges() {
        let expect = expectation(description: "")
        let inserted = CoreDataTests.createTestManagedObjects(inContext: self.mainContext, count: 10)
        mainContext.perform {
            try! self.mainContext.save()
        }
        
        let results = allThings() { result, changes in
            let objects = try! result.resolve()
            if changes == nil {
                XCTAssertEqual(objects.count, 10)
                return
            }
            
            XCTAssertEqual(objects.count, 10)
            XCTAssertEqual(changes!.count, 1)
            
            switch changes![0] {
            case .move(from: _, to: _):
                break
            default:
                XCTFail()
            }
            
            expect.fulfill()
        }
        
        let thing = inserted[0]
        mainContext.perform {
            thing.title = "Z"
            try! self.mainContext.save()
        }
        
        waitForExpectations(timeout: defaultTimeout)
        results.cleanUp()
    }
    
    
    func testReconfigureFetchRequest() {
        let expect1 = expectation(description: "1")
        let expect2 = expectation(description: "2")
        
        CoreDataTests.createTestManagedObjects(inContext: self.mainContext, count: 9)
        
        TestEntity.insertObject(withUniqueKeyValue: "testid", inContext: self.mainContext)
        
        mainContext.perform {
            try! self.mainContext.save()
        }
        
        let results = allThings() { result, changes in
            let objects = try! result.resolve()
            if objects.count == 10 {
                expect1.fulfill()
            }
            
            if objects.count == 1 {
                let obj = objects[(0, 0)]
                XCTAssertEqual(obj.uniqueID!, "testid")
                expect2.fulfill()
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            results.reconfigureFetchRequest { fr in
                fr.predicate = NSPredicate(format: "uniqueID == %@", "testid")
            }
        }
        
        waitForExpectations(timeout: defaultTimeout)
        results.cleanUp()
    }
    

    func allThings(_ onChange: @escaping (Result<FetchedCollection<TestEntity>>, [DataProviderUpdate<TestEntity>]?) -> Void) -> FetchedCollection<TestEntity> {
        return FetchedCollection<TestEntity>(fetchRequest: TestEntity.sortedFetchRequest(),
                                     managedObjectContext: mainContext,
                                     onChange: onChange)
        
    }
    
    func sectionedThings(_ onChange: @escaping (Result<FetchedCollection<TestEntity>>, [DataProviderUpdate<TestEntity>]?) -> Void) -> FetchedCollection<TestEntity> {
        return FetchedCollection<TestEntity>(fetchRequest: TestEntity.sortedFetchRequest(),
                                     managedObjectContext: mainContext,
                                     sectionNameKeyPath: #keyPath(TestEntity.uniqueID),
                                     onChange: onChange)
    }
}
