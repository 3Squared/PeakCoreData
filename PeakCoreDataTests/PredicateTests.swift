//
//  PredicateTests.swift
//  PeakCoreDataTests
//
//  Created by David Yates on 13/02/2019.
//  Copyright © 2019 3Squared Ltd. All rights reserved.
//

import XCTest
@testable import PeakCoreData

class PredicateTests: XCTestCase {
    
    class Parent: NSObject {
        @objc let children: [Object]
        
        init(children: [Object]) {
            self.children = children
            super.init()
        }
    }
    
    class Object: NSObject {
        @objc let name: String
        @objc let count: Int
        
        init(name: String, count: Int) {
            self.name = name
            self.count = count
            super.init()
        }
    }
    
    lazy var jam = Object(name: "Jam", count: 4)
    lazy var elephants = Object(name: "Elephants", count: 3)
    lazy var peanuts = Object(name: "Peanuts", count: 2)
    lazy var one = [jam]
    lazy var two = [jam, elephants]
    lazy var three = [jam, elephants, peanuts]
    lazy var oneChild = Parent(children: one)
    lazy var twoChildren = Parent(children: two)
    lazy var threeChildren = Parent(children: three)
    
    func testEquals() {
        let selfPredicate = NSPredicate(equals: jam)
        XCTAssertTrue(selfPredicate.evaluate(with: jam))
        XCTAssertFalse(selfPredicate.evaluate(with: elephants))
        XCTAssertFalse(selfPredicate.evaluate(with: peanuts))
        
        let keyPathPredicate = NSPredicate(keyPath: #keyPath(Object.name), equals: "Jam")
        XCTAssertTrue(keyPathPredicate.evaluate(with: jam))
        XCTAssertFalse(keyPathPredicate.evaluate(with: elephants))
        XCTAssertFalse(keyPathPredicate.evaluate(with: peanuts))
    }
    
    func testNotEquals() {
        let selfPredicate = NSPredicate(doesNotEqual: jam)
        XCTAssertFalse(selfPredicate.evaluate(with: jam))
        XCTAssertTrue(selfPredicate.evaluate(with: elephants))
        XCTAssertTrue(selfPredicate.evaluate(with: peanuts))
        
        let keyPathPredicate = NSPredicate(keyPath: #keyPath(Object.name), doesNotEqual: "Jam")
        XCTAssertFalse(keyPathPredicate.evaluate(with: jam))
        XCTAssertTrue(keyPathPredicate.evaluate(with: elephants))
        XCTAssertTrue(keyPathPredicate.evaluate(with: peanuts))
    }
    
    func testLessThan() {
        let selfPredicate = NSPredicate(lessThan: 3)
        XCTAssertFalse(selfPredicate.evaluate(with: jam.count))
        XCTAssertFalse(selfPredicate.evaluate(with: elephants.count))
        XCTAssertTrue(selfPredicate.evaluate(with: peanuts.count))
        
        let keyPathPredicate = NSPredicate(keyPath: #keyPath(Object.count), lessThan: 3)
        XCTAssertFalse(keyPathPredicate.evaluate(with: jam))
        XCTAssertFalse(keyPathPredicate.evaluate(with: elephants))
        XCTAssertTrue(keyPathPredicate.evaluate(with: peanuts))
    }
    
    func testLessThanOrEqualTo() {
        let selfPredicate = NSPredicate(lessThanOrEqualTo: 3)
        XCTAssertFalse(selfPredicate.evaluate(with: jam.count))
        XCTAssertTrue(selfPredicate.evaluate(with: elephants.count))
        XCTAssertTrue(selfPredicate.evaluate(with: peanuts.count))
        
        let keyPathPredicate = NSPredicate(keyPath: #keyPath(Object.count), lessThanOrEqualTo: 3)
        XCTAssertFalse(keyPathPredicate.evaluate(with: jam))
        XCTAssertTrue(keyPathPredicate.evaluate(with: elephants))
        XCTAssertTrue(keyPathPredicate.evaluate(with: peanuts))
    }
    
    func testGreaterThan() {
        let selfPredicate = NSPredicate(greaterThan: 3)
        XCTAssertTrue(selfPredicate.evaluate(with: jam.count))
        XCTAssertFalse(selfPredicate.evaluate(with: elephants.count))
        XCTAssertFalse(selfPredicate.evaluate(with: peanuts.count))
        
        let keyPathPredicate = NSPredicate(keyPath: #keyPath(Object.count), greaterThan: 3)
        XCTAssertTrue(keyPathPredicate.evaluate(with: jam))
        XCTAssertFalse(keyPathPredicate.evaluate(with: elephants))
        XCTAssertFalse(keyPathPredicate.evaluate(with: peanuts))
    }
    
    func testGreaterThanOrEqualTo() {
        let selfPredicate = NSPredicate(greaterThanOrEqualTo: 3)
        XCTAssertTrue(selfPredicate.evaluate(with: jam.count))
        XCTAssertTrue(selfPredicate.evaluate(with: elephants.count))
        XCTAssertFalse(selfPredicate.evaluate(with: peanuts.count))
        
        let keyPathPredicate = NSPredicate(keyPath: #keyPath(Object.count), greaterThanOrEqualTo: 3)
        XCTAssertTrue(keyPathPredicate.evaluate(with: jam))
        XCTAssertTrue(keyPathPredicate.evaluate(with: elephants))
        XCTAssertFalse(keyPathPredicate.evaluate(with: peanuts))
    }
    
    func testCountEquals() {
        let selfPredicate = NSPredicate(countEquals: 3)
        XCTAssertFalse(selfPredicate.evaluate(with: one))
        XCTAssertFalse(selfPredicate.evaluate(with: two))
        XCTAssertTrue(selfPredicate.evaluate(with: three))
        
        let keyPathPredicate = NSPredicate(keyPath: #keyPath(Parent.children), countEquals: 3)
        XCTAssertFalse(keyPathPredicate.evaluate(with: oneChild))
        XCTAssertFalse(keyPathPredicate.evaluate(with: twoChildren))
        XCTAssertTrue(keyPathPredicate.evaluate(with: threeChildren))
    }
    
    func testCountLessThan() {
        let selfPredicate = NSPredicate(countLessThan: 2)
        XCTAssertTrue(selfPredicate.evaluate(with: one))
        XCTAssertFalse(selfPredicate.evaluate(with: two))
        XCTAssertFalse(selfPredicate.evaluate(with: three))
        
        let keyPathPredicate = NSPredicate(keyPath: #keyPath(Parent.children), countLessThan: 2)
        XCTAssertTrue(keyPathPredicate.evaluate(with: oneChild))
        XCTAssertFalse(keyPathPredicate.evaluate(with: twoChildren))
        XCTAssertFalse(keyPathPredicate.evaluate(with: threeChildren))
    }
    
    func testCountLessThanOrEqualTo() {
        let selfPredicate = NSPredicate(countLessThanOrEqualTo: 2)
        XCTAssertTrue(selfPredicate.evaluate(with: one))
        XCTAssertTrue(selfPredicate.evaluate(with: two))
        XCTAssertFalse(selfPredicate.evaluate(with: three))
        
        let keyPathPredicate = NSPredicate(keyPath: #keyPath(Parent.children), countLessThanOrEqualTo: 2)
        XCTAssertTrue(keyPathPredicate.evaluate(with: oneChild))
        XCTAssertTrue(keyPathPredicate.evaluate(with: twoChildren))
        XCTAssertFalse(keyPathPredicate.evaluate(with: threeChildren))
    }
    
    func testCountGreaterThan() {
        let selfPredicate = NSPredicate(countGreaterThan: 2)
        XCTAssertFalse(selfPredicate.evaluate(with: one))
        XCTAssertFalse(selfPredicate.evaluate(with: two))
        XCTAssertTrue(selfPredicate.evaluate(with: three))
        
        let keyPathPredicate = NSPredicate(keyPath: #keyPath(Parent.children), countGreaterThan: 2)
        XCTAssertFalse(keyPathPredicate.evaluate(with: oneChild))
        XCTAssertFalse(keyPathPredicate.evaluate(with: twoChildren))
        XCTAssertTrue(keyPathPredicate.evaluate(with: threeChildren))
    }
    
    func testCountGreaterThanOrEqualTo() {
        let selfPredicate = NSPredicate(countGreaterThanOrEqualTo: 2)
        XCTAssertFalse(selfPredicate.evaluate(with: one))
        XCTAssertTrue(selfPredicate.evaluate(with: two))
        XCTAssertTrue(selfPredicate.evaluate(with: three))
        
        let keyPathPredicate = NSPredicate(keyPath: #keyPath(Parent.children), countGreaterThanOrEqualTo: 2)
        XCTAssertFalse(keyPathPredicate.evaluate(with: oneChild))
        XCTAssertTrue(keyPathPredicate.evaluate(with: twoChildren))
        XCTAssertTrue(keyPathPredicate.evaluate(with: threeChildren))
    }
    
    func testIsIncludedIn() {
        let selfPredicate = NSPredicate(isIncludedIn: two)
        XCTAssertTrue(selfPredicate.evaluate(with: jam))
        XCTAssertTrue(selfPredicate.evaluate(with: elephants))
        XCTAssertFalse(selfPredicate.evaluate(with: peanuts))
        
        let keyPathPredicate = NSPredicate(keyPath: #keyPath(Object.name), isIncludedIn: two.map { $0.name })
        XCTAssertTrue(keyPathPredicate.evaluate(with: jam))
        XCTAssertTrue(keyPathPredicate.evaluate(with: elephants))
        XCTAssertFalse(keyPathPredicate.evaluate(with: peanuts))
    }
    
    func testIsNotIncludedIn() {
        let selfPredicate = NSPredicate(isNotIncludedIn: two)
        XCTAssertFalse(selfPredicate.evaluate(with: jam))
        XCTAssertFalse(selfPredicate.evaluate(with: elephants))
        XCTAssertTrue(selfPredicate.evaluate(with: peanuts))
        
        let keyPathPredicate = NSPredicate(keyPath: #keyPath(Object.name), isNotIncludedIn: two.map { $0.name })
        XCTAssertFalse(keyPathPredicate.evaluate(with: jam))
        XCTAssertFalse(keyPathPredicate.evaluate(with: elephants))
        XCTAssertTrue(keyPathPredicate.evaluate(with: peanuts))
    }
    
    func testContainsString() {
        let testString = "eph"
        let selfPredicate = NSPredicate(containsString: testString)
        XCTAssertFalse(selfPredicate.evaluate(with: jam.name))
        XCTAssertTrue(selfPredicate.evaluate(with: elephants.name))
        XCTAssertFalse(selfPredicate.evaluate(with: peanuts.name))
        
        let keyPathPredicate = NSPredicate(keyPath: #keyPath(Object.name), containsString: testString)
        XCTAssertFalse(keyPathPredicate.evaluate(with: jam))
        XCTAssertTrue(keyPathPredicate.evaluate(with: elephants))
        XCTAssertFalse(keyPathPredicate.evaluate(with: peanuts))
    }
    
    func testBeginsWith() {
        let testString = "ele"
        let selfPredicate = NSPredicate(beginsWith: testString)
        XCTAssertFalse(selfPredicate.evaluate(with: jam.name))
        XCTAssertTrue(selfPredicate.evaluate(with: elephants.name))
        XCTAssertFalse(selfPredicate.evaluate(with: peanuts.name))
        
        let keyPathPredicate = NSPredicate(keyPath: #keyPath(Object.name), beginsWith: testString)
        XCTAssertFalse(keyPathPredicate.evaluate(with: jam))
        XCTAssertTrue(keyPathPredicate.evaluate(with: elephants))
        XCTAssertFalse(keyPathPredicate.evaluate(with: peanuts))
    }
    
    func testEndsWith() {
        let testString = "nts"
        let selfPredicate = NSPredicate(endsWith: testString)
        XCTAssertFalse(selfPredicate.evaluate(with: jam.name))
        XCTAssertTrue(selfPredicate.evaluate(with: elephants.name))
        XCTAssertFalse(selfPredicate.evaluate(with: peanuts.name))
        
        let keyPathPredicate = NSPredicate(keyPath: #keyPath(Object.name), endsWith: testString)
        XCTAssertFalse(keyPathPredicate.evaluate(with: jam))
        XCTAssertTrue(keyPathPredicate.evaluate(with: elephants))
        XCTAssertFalse(keyPathPredicate.evaluate(with: peanuts))
    }
}
