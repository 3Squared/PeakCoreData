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
    
    lazy var object1 = Object(name: "ABC Object 1", count: 4)
    lazy var object2 = Object(name: "DEF Object 2", count: 3)
    lazy var object3 = Object(name: "GHI Object 3", count: 2)
    lazy var oneObject = [object1]
    lazy var twoObjects = [object1, object2]
    lazy var threeObjects = [object1, object2, object3]
    lazy var oneChild = Parent(children: oneObject)
    lazy var twoChildren = Parent(children: twoObjects)
    lazy var threeChildren = Parent(children: threeObjects)
    
    func testEqualTo() {
        let selfPredicate = NSPredicate(equalTo: object1)
        XCTAssertTrue(selfPredicate.evaluate(with: object1))
        XCTAssertFalse(selfPredicate.evaluate(with: object2))
        XCTAssertFalse(selfPredicate.evaluate(with: object3))
        
        let stringPredicate = NSPredicate(equalTo: "ABC Object 1", keyPath: #keyPath(Object.name))
        XCTAssertTrue(stringPredicate.evaluate(with: object1))
        XCTAssertFalse(stringPredicate.evaluate(with: object2))
        XCTAssertFalse(stringPredicate.evaluate(with: object3))
        
        let countPredicate = NSPredicate(equalTo: 3, keyPath: #keyPath(Object.count))
        XCTAssertFalse(countPredicate.evaluate(with: object1))
        XCTAssertTrue(countPredicate.evaluate(with: object2))
        XCTAssertFalse(countPredicate.evaluate(with: object3))
    }
    
    func testNotEqualTo() {
        let selfPredicate = NSPredicate(notEqualTo: object1)
        XCTAssertFalse(selfPredicate.evaluate(with: object1))
        XCTAssertTrue(selfPredicate.evaluate(with: object2))
        XCTAssertTrue(selfPredicate.evaluate(with: object3))
        
        let stringPredicate = NSPredicate(notEqualTo: "ABC Object 1", keyPath: #keyPath(Object.name))
        XCTAssertFalse(stringPredicate.evaluate(with: object1))
        XCTAssertTrue(stringPredicate.evaluate(with: object2))
        XCTAssertTrue(stringPredicate.evaluate(with: object3))
        
        let countPredicate = NSPredicate(notEqualTo: 3, keyPath: #keyPath(Object.count))
        XCTAssertTrue(countPredicate.evaluate(with: object1))
        XCTAssertFalse(countPredicate.evaluate(with: object2))
        XCTAssertTrue(countPredicate.evaluate(with: object3))
    }
    
    func testLessThan() {
        let selfPredicate = NSPredicate(lessThan: 3)
        XCTAssertFalse(selfPredicate.evaluate(with: object1.count))
        XCTAssertFalse(selfPredicate.evaluate(with: object2.count))
        XCTAssertTrue(selfPredicate.evaluate(with: object3.count))
        
        let keyPathPredicate = NSPredicate(lessThan: 3, keyPath: #keyPath(Object.count))
        XCTAssertFalse(keyPathPredicate.evaluate(with: object1))
        XCTAssertFalse(keyPathPredicate.evaluate(with: object2))
        XCTAssertTrue(keyPathPredicate.evaluate(with: object3))
    }
    
    func testLessThanOrEqualTo() {
        let selfPredicate = NSPredicate(lessThanOrEqualTo: 3)
        XCTAssertFalse(selfPredicate.evaluate(with: object1.count))
        XCTAssertTrue(selfPredicate.evaluate(with: object2.count))
        XCTAssertTrue(selfPredicate.evaluate(with: object3.count))
        
        let keyPathPredicate = NSPredicate(lessThanOrEqualTo: 3, keyPath: #keyPath(Object.count))
        XCTAssertFalse(keyPathPredicate.evaluate(with: object1))
        XCTAssertTrue(keyPathPredicate.evaluate(with: object2))
        XCTAssertTrue(keyPathPredicate.evaluate(with: object3))
    }
    
    func testGreaterThan() {
        let selfPredicate = NSPredicate(greaterThan: 3)
        XCTAssertTrue(selfPredicate.evaluate(with: object1.count))
        XCTAssertFalse(selfPredicate.evaluate(with: object2.count))
        XCTAssertFalse(selfPredicate.evaluate(with: object3.count))
        
        let keyPathPredicate = NSPredicate(greaterThan: 3, keyPath: #keyPath(Object.count))
        XCTAssertTrue(keyPathPredicate.evaluate(with: object1))
        XCTAssertFalse(keyPathPredicate.evaluate(with: object2))
        XCTAssertFalse(keyPathPredicate.evaluate(with: object3))
    }
    
    func testGreaterThanOrEqualTo() {
        let selfPredicate = NSPredicate(greaterThanOrEqualTo: 3)
        XCTAssertTrue(selfPredicate.evaluate(with: object1.count))
        XCTAssertTrue(selfPredicate.evaluate(with: object2.count))
        XCTAssertFalse(selfPredicate.evaluate(with: object3.count))
        
        let keyPathPredicate = NSPredicate(greaterThanOrEqualTo: 3, keyPath: #keyPath(Object.count))
        XCTAssertTrue(keyPathPredicate.evaluate(with: object1))
        XCTAssertTrue(keyPathPredicate.evaluate(with: object2))
        XCTAssertFalse(keyPathPredicate.evaluate(with: object3))
    }
    
    func testCountEqualTo() {
        let selfPredicate = NSPredicate(countEqualTo: 3)
        XCTAssertFalse(selfPredicate.evaluate(with: oneObject))
        XCTAssertFalse(selfPredicate.evaluate(with: twoObjects))
        XCTAssertTrue(selfPredicate.evaluate(with: threeObjects))
        
        let keyPathPredicate = NSPredicate(countEqualTo: 3, keyPath: #keyPath(Parent.children))
        XCTAssertFalse(keyPathPredicate.evaluate(with: oneChild))
        XCTAssertFalse(keyPathPredicate.evaluate(with: twoChildren))
        XCTAssertTrue(keyPathPredicate.evaluate(with: threeChildren))
    }
    
    func testCountNotEqualTo() {
        let selfPredicate = NSPredicate(countNotEqualTo: 3)
        XCTAssertTrue(selfPredicate.evaluate(with: oneObject))
        XCTAssertTrue(selfPredicate.evaluate(with: twoObjects))
        XCTAssertFalse(selfPredicate.evaluate(with: threeObjects))
        
        let keyPathPredicate = NSPredicate(countNotEqualTo: 3, keyPath: #keyPath(Parent.children))
        XCTAssertTrue(keyPathPredicate.evaluate(with: oneChild))
        XCTAssertTrue(keyPathPredicate.evaluate(with: twoChildren))
        XCTAssertFalse(keyPathPredicate.evaluate(with: threeChildren))
    }
    
    func testCountLessThan() {
        let selfPredicate = NSPredicate(countLessThan: 2)
        XCTAssertTrue(selfPredicate.evaluate(with: oneObject))
        XCTAssertFalse(selfPredicate.evaluate(with: twoObjects))
        XCTAssertFalse(selfPredicate.evaluate(with: threeObjects))
        
        let keyPathPredicate = NSPredicate(countLessThan: 2, keyPath: #keyPath(Parent.children))
        XCTAssertTrue(keyPathPredicate.evaluate(with: oneChild))
        XCTAssertFalse(keyPathPredicate.evaluate(with: twoChildren))
        XCTAssertFalse(keyPathPredicate.evaluate(with: threeChildren))
    }
    
    func testCountLessThanOrEqualTo() {
        let selfPredicate = NSPredicate(countLessThanOrEqualTo: 2)
        XCTAssertTrue(selfPredicate.evaluate(with: oneObject))
        XCTAssertTrue(selfPredicate.evaluate(with: twoObjects))
        XCTAssertFalse(selfPredicate.evaluate(with: threeObjects))
        
        let keyPathPredicate = NSPredicate(countLessThanOrEqualTo: 2, keyPath: #keyPath(Parent.children))
        XCTAssertTrue(keyPathPredicate.evaluate(with: oneChild))
        XCTAssertTrue(keyPathPredicate.evaluate(with: twoChildren))
        XCTAssertFalse(keyPathPredicate.evaluate(with: threeChildren))
    }
    
    func testCountGreaterThan() {
        let selfPredicate = NSPredicate(countGreaterThan: 2)
        XCTAssertFalse(selfPredicate.evaluate(with: oneObject))
        XCTAssertFalse(selfPredicate.evaluate(with: twoObjects))
        XCTAssertTrue(selfPredicate.evaluate(with: threeObjects))
        
        let keyPathPredicate = NSPredicate(countGreaterThan: 2, keyPath: #keyPath(Parent.children))
        XCTAssertFalse(keyPathPredicate.evaluate(with: oneChild))
        XCTAssertFalse(keyPathPredicate.evaluate(with: twoChildren))
        XCTAssertTrue(keyPathPredicate.evaluate(with: threeChildren))
    }
    
    func testCountGreaterThanOrEqualTo() {
        let selfPredicate = NSPredicate(countGreaterThanOrEqualTo: 2)
        XCTAssertFalse(selfPredicate.evaluate(with: oneObject))
        XCTAssertTrue(selfPredicate.evaluate(with: twoObjects))
        XCTAssertTrue(selfPredicate.evaluate(with: threeObjects))
        
        let keyPathPredicate = NSPredicate(countGreaterThanOrEqualTo: 2, keyPath: #keyPath(Parent.children))
        XCTAssertFalse(keyPathPredicate.evaluate(with: oneChild))
        XCTAssertTrue(keyPathPredicate.evaluate(with: twoChildren))
        XCTAssertTrue(keyPathPredicate.evaluate(with: threeChildren))
    }
    
    func testIsIncludedIn() {
        let selfPredicate = NSPredicate(isIncludedIn: twoObjects)
        XCTAssertTrue(selfPredicate.evaluate(with: object1))
        XCTAssertTrue(selfPredicate.evaluate(with: object2))
        XCTAssertFalse(selfPredicate.evaluate(with: object3))
        
        let array = twoObjects.map { $0.name }
        let keyPathPredicate = NSPredicate(isIncludedIn: array, keyPath: #keyPath(Object.name))
        XCTAssertTrue(keyPathPredicate.evaluate(with: object1))
        XCTAssertTrue(keyPathPredicate.evaluate(with: object2))
        XCTAssertFalse(keyPathPredicate.evaluate(with: object3))
    }
    
    func testIsNotIncludedIn() {
        let selfPredicate = NSPredicate(isNotIncludedIn: twoObjects)
        XCTAssertFalse(selfPredicate.evaluate(with: object1))
        XCTAssertFalse(selfPredicate.evaluate(with: object2))
        XCTAssertTrue(selfPredicate.evaluate(with: object3))
        
        let array = twoObjects.map { $0.name }
        let keyPathPredicate = NSPredicate(isNotIncludedIn: array, keyPath: #keyPath(Object.name))
        XCTAssertFalse(keyPathPredicate.evaluate(with: object1))
        XCTAssertFalse(keyPathPredicate.evaluate(with: object2))
        XCTAssertTrue(keyPathPredicate.evaluate(with: object3))
    }
    
    func testAnyEquals() {
        let selfPredicate = NSPredicate(anyEquals: object3)
        XCTAssertFalse(selfPredicate.evaluate(with: oneObject))
        XCTAssertFalse(selfPredicate.evaluate(with: twoObjects))
        XCTAssertTrue(selfPredicate.evaluate(with: threeObjects))
        
        let keyPathPredicate = NSPredicate(anyEquals: object3, keyPath: #keyPath(Parent.children))
        XCTAssertFalse(keyPathPredicate.evaluate(with: oneChild))
        XCTAssertFalse(keyPathPredicate.evaluate(with: twoChildren))
        XCTAssertTrue(keyPathPredicate.evaluate(with: threeChildren))
        
        let subquery = NSPredicate(format: "SUBQUERY(%K, $child, ($child == %@)).@count > 0", argumentArray: [#keyPath(Parent.children), object3])
        XCTAssertFalse(subquery.evaluate(with: oneChild))
        XCTAssertFalse(subquery.evaluate(with: twoChildren))
        XCTAssertTrue(subquery.evaluate(with: threeChildren))
    }
    
    func testAnyEqualsNested() {
        let keyPathPredicate = NSPredicate(anyEquals: 3, keyPath: #keyPath(Parent.children.count))
        XCTAssertFalse(keyPathPredicate.evaluate(with: oneChild))
        XCTAssertTrue(keyPathPredicate.evaluate(with: twoChildren))
        XCTAssertTrue(keyPathPredicate.evaluate(with: threeChildren))
        
        let subquery = NSPredicate(format: "SUBQUERY(%K, $child, ($child.%K == %@)).@count > 0", argumentArray: [#keyPath(Parent.children), #keyPath(Object.count), 3])
        XCTAssertFalse(subquery.evaluate(with: oneChild))
        XCTAssertTrue(subquery.evaluate(with: twoChildren))
        XCTAssertTrue(subquery.evaluate(with: threeChildren))
    }
    
    func testAnyIn() {
        let selfPredicate = NSPredicate(anyIn: [object2, object3])
        XCTAssertFalse(selfPredicate.evaluate(with: oneObject))
        XCTAssertTrue(selfPredicate.evaluate(with: twoObjects))
        XCTAssertTrue(selfPredicate.evaluate(with: threeObjects))
        
        let keyPathPredicate = NSPredicate(anyIn: [object2, object3], keyPath: #keyPath(Parent.children))
        XCTAssertFalse(keyPathPredicate.evaluate(with: oneChild))
        XCTAssertTrue(keyPathPredicate.evaluate(with: twoChildren))
        XCTAssertTrue(keyPathPredicate.evaluate(with: threeChildren))
        
        let subquery = NSPredicate(format: "SUBQUERY(%K, $child, ($child IN %@)).@count > 0", argumentArray: [#keyPath(Parent.children), [object2, object3]])
        XCTAssertFalse(subquery.evaluate(with: oneChild))
        XCTAssertTrue(subquery.evaluate(with: twoChildren))
        XCTAssertTrue(subquery.evaluate(with: threeChildren))
    }
    
    func testAnyInNested() {
        let keyPathPredicate = NSPredicate(anyIn: [3, 2], keyPath: #keyPath(Parent.children.count))
        XCTAssertFalse(keyPathPredicate.evaluate(with: oneChild))
        XCTAssertTrue(keyPathPredicate.evaluate(with: twoChildren))
        XCTAssertTrue(keyPathPredicate.evaluate(with: threeChildren))
        
        let subquery = NSPredicate(format: "SUBQUERY(%K, $child, ($child.%K IN %@)).@count > 0", argumentArray: [#keyPath(Parent.children), #keyPath(Object.count), [3, 2]])
        XCTAssertFalse(subquery.evaluate(with: oneChild))
        XCTAssertTrue(subquery.evaluate(with: twoChildren))
        XCTAssertTrue(subquery.evaluate(with: threeChildren))
    }
    
    func testStringContains() {
        let testString = "JECT 2"
        let selfPredicate = NSPredicate(stringContains: testString)
        XCTAssertFalse(selfPredicate.evaluate(with: object1.name))
        XCTAssertTrue(selfPredicate.evaluate(with: object2.name))
        XCTAssertFalse(selfPredicate.evaluate(with: object3.name))
        
        let keyPathPredicate = NSPredicate(stringContains: testString, keyPath: #keyPath(Object.name))
        XCTAssertFalse(keyPathPredicate.evaluate(with: object1))
        XCTAssertTrue(keyPathPredicate.evaluate(with: object2))
        XCTAssertFalse(keyPathPredicate.evaluate(with: object3))
    }
    
    func testStringContainsCaseSensitive() {
        let testString = "JECT 2"
        let selfPredicate = NSPredicate(stringContains: testString, caseInsensitive: false)
        XCTAssertFalse(selfPredicate.evaluate(with: object1.name))
        XCTAssertFalse(selfPredicate.evaluate(with: object2.name))
        XCTAssertFalse(selfPredicate.evaluate(with: object3.name))
        
        let keyPathPredicate = NSPredicate(stringContains: testString, keyPath: #keyPath(Object.name), caseInsensitive: false)
        XCTAssertFalse(keyPathPredicate.evaluate(with: object1))
        XCTAssertFalse(keyPathPredicate.evaluate(with: object2))
        XCTAssertFalse(keyPathPredicate.evaluate(with: object3))
    }
    
    func testStringBeginsWith() {
        let testString = "def"
        let selfPredicate = NSPredicate(stringBeginsWith: testString)
        XCTAssertFalse(selfPredicate.evaluate(with: object1.name))
        XCTAssertTrue(selfPredicate.evaluate(with: object2.name))
        XCTAssertFalse(selfPredicate.evaluate(with: object3.name))
        
        let keyPathPredicate = NSPredicate(stringBeginsWith: testString, keyPath: #keyPath(Object.name))
        XCTAssertFalse(keyPathPredicate.evaluate(with: object1))
        XCTAssertTrue(keyPathPredicate.evaluate(with: object2))
        XCTAssertFalse(keyPathPredicate.evaluate(with: object3))
    }
    
    func testStringBeginsWithCaseSensitive() {
        let testString = "def"
        let selfPredicate = NSPredicate(stringBeginsWith: testString, caseInsensitive: false)
        XCTAssertFalse(selfPredicate.evaluate(with: object1.name))
        XCTAssertFalse(selfPredicate.evaluate(with: object2.name))
        XCTAssertFalse(selfPredicate.evaluate(with: object3.name))
        
        let keyPathPredicate = NSPredicate(stringBeginsWith: testString, keyPath: #keyPath(Object.name), caseInsensitive: false)
        XCTAssertFalse(keyPathPredicate.evaluate(with: object1))
        XCTAssertFalse(keyPathPredicate.evaluate(with: object2))
        XCTAssertFalse(keyPathPredicate.evaluate(with: object3))
    }
    
    func testStringEquals() {
        let testString = "def object 2"
        let selfPredicate = NSPredicate(stringEquals: testString)
        XCTAssertFalse(selfPredicate.evaluate(with: object1.name))
        XCTAssertTrue(selfPredicate.evaluate(with: object2.name))
        XCTAssertFalse(selfPredicate.evaluate(with: object3.name))
        
        let keyPathPredicate = NSPredicate(stringEquals: testString, keyPath: #keyPath(Object.name))
        XCTAssertFalse(keyPathPredicate.evaluate(with: object1))
        XCTAssertTrue(keyPathPredicate.evaluate(with: object2))
        XCTAssertFalse(keyPathPredicate.evaluate(with: object3))
    }
    
    func testStringEqualsCaseSensitive() {
        let testString = "def object 2"
        let selfPredicate = NSPredicate(stringEquals: testString, caseInsensitive: false)
        XCTAssertFalse(selfPredicate.evaluate(with: object1.name))
        XCTAssertFalse(selfPredicate.evaluate(with: object2.name))
        XCTAssertFalse(selfPredicate.evaluate(with: object3.name))
        
        let keyPathPredicate = NSPredicate(stringEquals: testString, keyPath: #keyPath(Object.name), caseInsensitive: false)
        XCTAssertFalse(keyPathPredicate.evaluate(with: object1))
        XCTAssertFalse(keyPathPredicate.evaluate(with: object2))
        XCTAssertFalse(keyPathPredicate.evaluate(with: object3))
    }
    
    func testStringEndsWith() {
        let testString = "ECT 2"
        let selfPredicate = NSPredicate(stringEndsWith: testString)
        XCTAssertFalse(selfPredicate.evaluate(with: object1.name))
        XCTAssertTrue(selfPredicate.evaluate(with: object2.name))
        XCTAssertFalse(selfPredicate.evaluate(with: object3.name))
        
        let keyPathPredicate = NSPredicate(stringEndsWith: testString, keyPath: #keyPath(Object.name))
        XCTAssertFalse(keyPathPredicate.evaluate(with: object1))
        XCTAssertTrue(keyPathPredicate.evaluate(with: object2))
        XCTAssertFalse(keyPathPredicate.evaluate(with: object3))
    }
    
    func testStringEndsWithCaseSensitive() {
        let testString = "ECT 2"
        let selfPredicate = NSPredicate(stringEndsWith: testString, caseInsensitive: false)
        XCTAssertFalse(selfPredicate.evaluate(with: object1.name))
        XCTAssertFalse(selfPredicate.evaluate(with: object2.name))
        XCTAssertFalse(selfPredicate.evaluate(with: object3.name))
        
        let keyPathPredicate = NSPredicate(stringEndsWith: testString, keyPath: #keyPath(Object.name), caseInsensitive: false)
        XCTAssertFalse(keyPathPredicate.evaluate(with: object1))
        XCTAssertFalse(keyPathPredicate.evaluate(with: object2))
        XCTAssertFalse(keyPathPredicate.evaluate(with: object3))
    }
}
