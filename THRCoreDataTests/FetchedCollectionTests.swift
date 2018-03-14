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
        CoreDataTests.createTestManagedObjects(in: viewContext, count: 10)
        
        let expect = expectation(description: "")
        let results = allThings { _, update in
            if update != nil { expect.fulfill() }
        }

        let snap = results.snapshot()
        
        XCTAssertEqual(results.count, 10)
        XCTAssertEqual(snap.count, 10)
        
        viewContext.performAndWait {
            self.viewContext.delete(results[(0, 0)])
        }
        
        waitForExpectations(timeout: defaultTimeout)
        
        XCTAssertEqual(results.count, 9)
        XCTAssertEqual(snap.count, 10)
    }
        
    func testSectionedResults() {
        CoreDataTests.createTestManagedObjects(in: viewContext, count: 10)
        
        let results = sectionedThings() { _, _ in }
        XCTAssertEqual(results.sections.count, 10)
        
        results.sections.forEach { section in
            XCTAssertEqual(section.numberOfObjects, 1)
        }
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
        
        viewContext.perform {
            CoreDataTests.createTestManagedObjects(in: self.viewContext, count: 10)
            try! self.viewContext.save()
        }
        
        waitForExpectations(timeout: defaultTimeout)
    }
    
    func testInsertSectionChanges() {
        CoreDataTests.createTestManagedObjects(in: viewContext, count: 1)
        try! viewContext.save()
        
        let results = sectionedThings() { _, _ in }
        XCTAssertEqual(results.sections.count, 1)
        
        viewContext.performAndWait {
            CoreDataTests.createTestManagedObjects(in: viewContext, count: 1)
            try! self.viewContext.save()
        }

        XCTAssertEqual(results.sections.count, 2)

        results.sections.forEach { section in
            XCTAssertEqual(section.numberOfObjects, 1)
        }
    }

    
    func testDeletionChanges() {
        let expect = expectation(description: "")
        let inserted = CoreDataTests.createTestManagedObjects(in: viewContext, count: 10)
        viewContext.perform {
            try! self.viewContext.save()
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
        viewContext.perform {
            self.viewContext.delete(thing)
            try! self.viewContext.save()
        }
        
        waitForExpectations(timeout: defaultTimeout)
    }
    
    
    func testUpdateChanges() {
        let expect = expectation(description: "")
        let inserted = CoreDataTests.createTestManagedObjects(in: viewContext, count: 10)
        viewContext.perform {
            try! self.viewContext.save()
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
            case .update(_, let object):
                XCTAssertEqual(object.uniqueID!, "what")
                break
            case .move(let from, let to):
                print("move from [\(from.row), \(from.section)] to [\(to.row), \(to.section)]")
                break
            default:
                XCTFail()
            }
            
            expect.fulfill()
        }
        
        let thing = inserted[0]
        viewContext.perform {
            thing.uniqueID = "what"
            try! self.viewContext.save()
        }
        
        waitForExpectations(timeout: defaultTimeout)
    }
    
    func testMoveChanges() {
        let expect = expectation(description: "")
        let inserted = CoreDataTests.createTestManagedObjects(in: viewContext, count: 10)
        
        let results = allThings() { result, changes in
            let objects = try! result.resolve()
            if changes == nil {
                XCTAssertEqual(objects.count, 10)
                return
            }
            
            XCTAssertEqual(objects.count, 10)
            XCTAssertEqual(changes!.count, 1)
            
            switch changes![0] {
            case .move(_, _):
                break
            default:
                XCTFail()
            }
            
            expect.fulfill()
        }
        
        let thing = inserted[0]
        viewContext.perform {
            thing.title = "Z"
            try! self.viewContext.save()
        }
        
        waitForExpectations(timeout: defaultTimeout)
    }
    
    
    func testReconfigureFetchRequest() {
        let expect1 = expectation(description: "1")
        let expect2 = expectation(description: "2")
        
        CoreDataTests.createTestManagedObjects(in: viewContext, count: 9)
        
        TestEntity.insertObject(with: "testid", in: viewContext)
        
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
    }
    

    func allThings(_ onChange: @escaping (Result<FetchedCollection<TestEntity>>, [FetchedUpdate<TestEntity>]?) -> Void) -> FetchedCollection<TestEntity> {
        return FetchedCollection<TestEntity>(fetchRequest: TestEntity.sortedFetchRequest(),
                                     managedObjectContext: viewContext,
                                     onChange: onChange)
        
    }
    
    func sectionedThings(_ onChange: @escaping (Result<FetchedCollection<TestEntity>>, [FetchedUpdate<TestEntity>]?) -> Void) -> FetchedCollection<TestEntity> {
        return FetchedCollection<TestEntity>(fetchRequest: TestEntity.sortedFetchRequest(),
                                     managedObjectContext: viewContext,
                                     sectionNameKeyPath: #keyPath(TestEntity.uniqueID),
                                     onChange: onChange)
    }
}
