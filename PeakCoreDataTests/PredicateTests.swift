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
    
    func testEqualTo() {
        let selfPredicate = NSPredicate(equalTo: jam)
        XCTAssertTrue(selfPredicate.evaluate(with: jam))
        XCTAssertFalse(selfPredicate.evaluate(with: elephants))
        XCTAssertFalse(selfPredicate.evaluate(with: peanuts))
        
        let keyPathPredicate = NSPredicate(equalTo: "Jam", keyPath: #keyPath(Object.name))
        XCTAssertTrue(keyPathPredicate.evaluate(with: jam))
        XCTAssertFalse(keyPathPredicate.evaluate(with: elephants))
        XCTAssertFalse(keyPathPredicate.evaluate(with: peanuts))
    }
    
    func testNotEqualTo() {
        let selfPredicate = NSPredicate(notEqualTo: jam)
        XCTAssertFalse(selfPredicate.evaluate(with: jam))
        XCTAssertTrue(selfPredicate.evaluate(with: elephants))
        XCTAssertTrue(selfPredicate.evaluate(with: peanuts))
        
        let keyPathPredicate = NSPredicate(notEqualTo: "Jam", keyPath: #keyPath(Object.name))
        XCTAssertFalse(keyPathPredicate.evaluate(with: jam))
        XCTAssertTrue(keyPathPredicate.evaluate(with: elephants))
        XCTAssertTrue(keyPathPredicate.evaluate(with: peanuts))
    }
    
    func testLessThan() {
        let selfPredicate = NSPredicate(lessThan: 3)
        XCTAssertFalse(selfPredicate.evaluate(with: jam.count))
        XCTAssertFalse(selfPredicate.evaluate(with: elephants.count))
        XCTAssertTrue(selfPredicate.evaluate(with: peanuts.count))
        
        let keyPathPredicate = NSPredicate(lessThan: 3, keyPath: #keyPath(Object.count))
        XCTAssertFalse(keyPathPredicate.evaluate(with: jam))
        XCTAssertFalse(keyPathPredicate.evaluate(with: elephants))
        XCTAssertTrue(keyPathPredicate.evaluate(with: peanuts))
    }
    
    func testLessThanOrEqualTo() {
        let selfPredicate = NSPredicate(lessThanOrEqualTo: 3)
        XCTAssertFalse(selfPredicate.evaluate(with: jam.count))
        XCTAssertTrue(selfPredicate.evaluate(with: elephants.count))
        XCTAssertTrue(selfPredicate.evaluate(with: peanuts.count))
        
        let keyPathPredicate = NSPredicate(lessThanOrEqualTo: 3, keyPath: #keyPath(Object.count))
        XCTAssertFalse(keyPathPredicate.evaluate(with: jam))
        XCTAssertTrue(keyPathPredicate.evaluate(with: elephants))
        XCTAssertTrue(keyPathPredicate.evaluate(with: peanuts))
    }
    
    func testGreaterThan() {
        let selfPredicate = NSPredicate(greaterThan: 3)
        XCTAssertTrue(selfPredicate.evaluate(with: jam.count))
        XCTAssertFalse(selfPredicate.evaluate(with: elephants.count))
        XCTAssertFalse(selfPredicate.evaluate(with: peanuts.count))
        
        let keyPathPredicate = NSPredicate(greaterThan: 3, keyPath: #keyPath(Object.count))
        XCTAssertTrue(keyPathPredicate.evaluate(with: jam))
        XCTAssertFalse(keyPathPredicate.evaluate(with: elephants))
        XCTAssertFalse(keyPathPredicate.evaluate(with: peanuts))
    }
    
    func testGreaterThanOrEqualTo() {
        let selfPredicate = NSPredicate(greaterThanOrEqualTo: 3)
        XCTAssertTrue(selfPredicate.evaluate(with: jam.count))
        XCTAssertTrue(selfPredicate.evaluate(with: elephants.count))
        XCTAssertFalse(selfPredicate.evaluate(with: peanuts.count))
        
        let keyPathPredicate = NSPredicate(greaterThanOrEqualTo: 3, keyPath: #keyPath(Object.count))
        XCTAssertTrue(keyPathPredicate.evaluate(with: jam))
        XCTAssertTrue(keyPathPredicate.evaluate(with: elephants))
        XCTAssertFalse(keyPathPredicate.evaluate(with: peanuts))
    }
    
    func testCountEqualTo() {
        let selfPredicate = NSPredicate(countEqualTo: 3)
        XCTAssertFalse(selfPredicate.evaluate(with: one))
        XCTAssertFalse(selfPredicate.evaluate(with: two))
        XCTAssertTrue(selfPredicate.evaluate(with: three))
        
        let keyPathPredicate = NSPredicate(countEqualTo: 3, keyPath: #keyPath(Parent.children))
        XCTAssertFalse(keyPathPredicate.evaluate(with: oneChild))
        XCTAssertFalse(keyPathPredicate.evaluate(with: twoChildren))
        XCTAssertTrue(keyPathPredicate.evaluate(with: threeChildren))
    }
    
    func testCountNotEqualTo() {
        let selfPredicate = NSPredicate(countNotEqualTo: 3)
        XCTAssertTrue(selfPredicate.evaluate(with: one))
        XCTAssertTrue(selfPredicate.evaluate(with: two))
        XCTAssertFalse(selfPredicate.evaluate(with: three))
        
        let keyPathPredicate = NSPredicate(countNotEqualTo: 3, keyPath: #keyPath(Parent.children))
        XCTAssertTrue(keyPathPredicate.evaluate(with: oneChild))
        XCTAssertTrue(keyPathPredicate.evaluate(with: twoChildren))
        XCTAssertFalse(keyPathPredicate.evaluate(with: threeChildren))
    }
    
    func testCountLessThan() {
        let selfPredicate = NSPredicate(countLessThan: 2)
        XCTAssertTrue(selfPredicate.evaluate(with: one))
        XCTAssertFalse(selfPredicate.evaluate(with: two))
        XCTAssertFalse(selfPredicate.evaluate(with: three))
        
        let keyPathPredicate = NSPredicate(countLessThan: 2, keyPath: #keyPath(Parent.children))
        XCTAssertTrue(keyPathPredicate.evaluate(with: oneChild))
        XCTAssertFalse(keyPathPredicate.evaluate(with: twoChildren))
        XCTAssertFalse(keyPathPredicate.evaluate(with: threeChildren))
    }
    
    func testCountLessThanOrEqualTo() {
        let selfPredicate = NSPredicate(countLessThanOrEqualTo: 2)
        XCTAssertTrue(selfPredicate.evaluate(with: one))
        XCTAssertTrue(selfPredicate.evaluate(with: two))
        XCTAssertFalse(selfPredicate.evaluate(with: three))
        
        let keyPathPredicate = NSPredicate(countLessThanOrEqualTo: 2, keyPath: #keyPath(Parent.children))
        XCTAssertTrue(keyPathPredicate.evaluate(with: oneChild))
        XCTAssertTrue(keyPathPredicate.evaluate(with: twoChildren))
        XCTAssertFalse(keyPathPredicate.evaluate(with: threeChildren))
    }
    
    func testCountGreaterThan() {
        let selfPredicate = NSPredicate(countGreaterThan: 2)
        XCTAssertFalse(selfPredicate.evaluate(with: one))
        XCTAssertFalse(selfPredicate.evaluate(with: two))
        XCTAssertTrue(selfPredicate.evaluate(with: three))
        
        let keyPathPredicate = NSPredicate(countGreaterThan: 2, keyPath: #keyPath(Parent.children))
        XCTAssertFalse(keyPathPredicate.evaluate(with: oneChild))
        XCTAssertFalse(keyPathPredicate.evaluate(with: twoChildren))
        XCTAssertTrue(keyPathPredicate.evaluate(with: threeChildren))
    }
    
    func testCountGreaterThanOrEqualTo() {
        let selfPredicate = NSPredicate(countGreaterThanOrEqualTo: 2)
        XCTAssertFalse(selfPredicate.evaluate(with: one))
        XCTAssertTrue(selfPredicate.evaluate(with: two))
        XCTAssertTrue(selfPredicate.evaluate(with: three))
        
        let keyPathPredicate = NSPredicate(countGreaterThanOrEqualTo: 2, keyPath: #keyPath(Parent.children))
        XCTAssertFalse(keyPathPredicate.evaluate(with: oneChild))
        XCTAssertTrue(keyPathPredicate.evaluate(with: twoChildren))
        XCTAssertTrue(keyPathPredicate.evaluate(with: threeChildren))
    }
    
    func testIsIncludedIn() {
        let selfPredicate = NSPredicate(isIncludedIn: two)
        XCTAssertTrue(selfPredicate.evaluate(with: jam))
        XCTAssertTrue(selfPredicate.evaluate(with: elephants))
        XCTAssertFalse(selfPredicate.evaluate(with: peanuts))
        
        let keyPathPredicate = NSPredicate(isIncludedIn: two.map { $0.name }, keyPath: #keyPath(Object.name))
        XCTAssertTrue(keyPathPredicate.evaluate(with: jam))
        XCTAssertTrue(keyPathPredicate.evaluate(with: elephants))
        XCTAssertFalse(keyPathPredicate.evaluate(with: peanuts))
    }
    
    func testIsNotIncludedIn() {
        let selfPredicate = NSPredicate(isNotIncludedIn: two)
        XCTAssertFalse(selfPredicate.evaluate(with: jam))
        XCTAssertFalse(selfPredicate.evaluate(with: elephants))
        XCTAssertTrue(selfPredicate.evaluate(with: peanuts))
        
        let keyPathPredicate = NSPredicate(isNotIncludedIn: two.map { $0.name }, keyPath: #keyPath(Object.name))
        XCTAssertFalse(keyPathPredicate.evaluate(with: jam))
        XCTAssertFalse(keyPathPredicate.evaluate(with: elephants))
        XCTAssertTrue(keyPathPredicate.evaluate(with: peanuts))
    }
    
    func testStringContains() {
        let testString = "eph"
        let selfPredicate = NSPredicate(stringContains: testString)
        XCTAssertFalse(selfPredicate.evaluate(with: jam.name))
        XCTAssertTrue(selfPredicate.evaluate(with: elephants.name))
        XCTAssertFalse(selfPredicate.evaluate(with: peanuts.name))
        
        let keyPathPredicate = NSPredicate(stringContains: testString, keyPath: #keyPath(Object.name))
        XCTAssertFalse(keyPathPredicate.evaluate(with: jam))
        XCTAssertTrue(keyPathPredicate.evaluate(with: elephants))
        XCTAssertFalse(keyPathPredicate.evaluate(with: peanuts))
    }
    
    func testStringBeginsWith() {
        let testString = "ele"
        let selfPredicate = NSPredicate(stringBeginsWith: testString)
        XCTAssertFalse(selfPredicate.evaluate(with: jam.name))
        XCTAssertTrue(selfPredicate.evaluate(with: elephants.name))
        XCTAssertFalse(selfPredicate.evaluate(with: peanuts.name))
        
        let keyPathPredicate = NSPredicate(stringBeginsWith: testString, keyPath: #keyPath(Object.name))
        XCTAssertFalse(keyPathPredicate.evaluate(with: jam))
        XCTAssertTrue(keyPathPredicate.evaluate(with: elephants))
        XCTAssertFalse(keyPathPredicate.evaluate(with: peanuts))
    }
    
    func testStringEndsWith() {
        let testString = "nts"
        let selfPredicate = NSPredicate(stringEndsWith: testString)
        XCTAssertFalse(selfPredicate.evaluate(with: jam.name))
        XCTAssertTrue(selfPredicate.evaluate(with: elephants.name))
        XCTAssertFalse(selfPredicate.evaluate(with: peanuts.name))
        
        let keyPathPredicate = NSPredicate(stringEndsWith: testString, keyPath: #keyPath(Object.name))
        XCTAssertFalse(keyPathPredicate.evaluate(with: jam))
        XCTAssertTrue(keyPathPredicate.evaluate(with: elephants))
        XCTAssertFalse(keyPathPredicate.evaluate(with: peanuts))
    }
}
