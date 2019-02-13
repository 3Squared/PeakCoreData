//
//  NSPredicate.swift
//  PeakCoreData
//
//  Created by David Yates on 13/02/2019.
//  Copyright © 2019 3Squared Ltd. All rights reserved.
//

import Foundation

// MARK: - Basic Comparison

extension NSPredicate {
    
    public typealias KeyPath = String
    
    /// Returns a predicate that performs and equals comparison.
    ///
    /// - Parameters:
    ///   - keyPath: The keypath to the property. Pass in `nil` to use SELF.
    ///   - value: The value to use in the comparison.
    public convenience init(keyPath: KeyPath? = nil, equals value: Any?) {
        if let keyPath = keyPath {
            if let value = value {
                self.init(format: "%K == %@", argumentArray: [keyPath, value])
            } else {
                self.init(format: "%K == nil", argumentArray: [keyPath])
            }
        } else {
            if let value = value {
                self.init(format: "SELF == %@", argumentArray: [value])
            } else {
                self.init(format: "SELF == nil")
            }
        }
    }
    
    /// Returns a predicate that performs a does not equal comparison.
    ///
    /// - Parameters:
    ///   - keyPath: The keypath to the property. Pass in `nil` to use SELF.
    ///   - value: The value to use in the comparison.
    public convenience init(keyPath: KeyPath? = nil, doesNotEqual value: Any?) {
        if let keyPath = keyPath {
            if let value = value {
                self.init(format: "%K != %@", argumentArray: [keyPath, value])
            } else {
                self.init(format: "%K != nil", argumentArray: [keyPath])
            }
        } else {
            if let value = value {
                self.init(format: "SELF != %@", argumentArray: [value])
            } else {
                self.init(format: "SELF != nil")
            }
        }
    }
    
    /// Returns a predicate that performs a less than comparison.
    ///
    /// - Parameters:
    ///   - keyPath: The keypath to the property. Pass in `nil` to use SELF.
    ///   - value: The value to use in the comparison.
    public convenience init(keyPath: KeyPath? = nil, lessThan value: Any) {
        if let keyPath = keyPath {
            self.init(format: "%K < %@", argumentArray: [keyPath, value])
        } else {
            self.init(format: "SELF < %@", argumentArray: [value])
        }
    }
    
    /// Returns a predicate that performs a less or equal to comparison.
    ///
    /// - Parameters:
    ///   - keyPath: The keypath to the property. Pass in `nil` to use SELF.
    ///   - value: The value to use in the comparison.
    public convenience init(keyPath: KeyPath? = nil, lessThanOrEqualTo value: Any) {
        if let keyPath = keyPath {
            self.init(format: "%K <= %@", argumentArray: [keyPath, value])
        } else {
            self.init(format: "SELF <= %@", argumentArray: [value])
        }
    }
    
    /// Returns a predicate that performs a greater than comparison.
    ///
    /// - Parameters:
    ///   - keyPath: The keypath to the property. Pass in `nil` to use SELF.
    ///   - value: The value to use in the comparison.
    public convenience init(keyPath: KeyPath? = nil, greaterThan value: Any) {
        if let keyPath = keyPath {
            self.init(format: "%K > %@", argumentArray: [keyPath, value])
        } else {
            self.init(format: "SELF > %@", argumentArray: [value])
        }
    }
    
    /// Returns a predicate that performs a greater than or equal to comparison.
    ///
    /// - Parameters:
    ///   - keyPath: The keypath to the property. Pass in `nil` to use SELF.
    ///   - value: The value to use in the comparison.
    public convenience init(keyPath: KeyPath? = nil, greaterThanOrEqualTo value: Any) {
        if let keyPath = keyPath {
            self.init(format: "%K >= %@", argumentArray: [keyPath, value])
        } else {
            self.init(format: "SELF >= %@", argumentArray: [value])
        }
    }
}

// MARK: - Count

extension NSPredicate {
    
    /// Returns a predicate that performs an equals comparison on a relationship count.
    ///
    /// - Parameters:
    ///   - keyPath: The keypath of the entity relationship. Pass in `nil` to use SELF.
    ///   - count: The count to use in the comparison.
    public convenience init(keyPath: KeyPath? = nil, countEquals count: Int) {
        if let keyPath = keyPath {
            self.init(format: "%K.@count == %@", argumentArray: [keyPath, count])
        } else {
            self.init(format: "SELF.@count == %@", argumentArray: [count])
        }
    }
    
    /// Returns a predicate that performs an does not equal comparison on a relationship count.
    ///
    /// - Parameters:
    ///   - keyPath: The keypath of the relationship. Pass in `nil` to use SELF.
    ///   - count: The count to use in the comparison.
    public convenience init(keyPath: KeyPath? = nil, countDoesNotEqual count: Int) {
        if let keyPath = keyPath {
            self.init(format: "%K.@count != %@", argumentArray: [keyPath, count])
        } else {
            self.init(format: "SELF.@count != %@", argumentArray: [count])
        }
    }
    
    /// Returns a predicate that performs a less than comparison on a relationship count.
    ///
    /// - Parameters:
    ///   - keyPath: The keypath of the relationship. Pass in `nil` to use SELF.
    ///   - count: The count to use in the comparison.
    public convenience init(keyPath: KeyPath? = nil, countLessThan value: Int) {
        if let keyPath = keyPath {
            self.init(format: "%K.@count < %@", argumentArray: [keyPath, value])
        } else {
            self.init(format: "SELF.@count < %@", argumentArray: [value])
        }
    }
    
    /// Returns a predicate that performs a less than or equal to comparison on a relationship count.
    ///
    /// - Parameters:
    ///   - keyPath: The keypath of the relationship. Pass in `nil` to use SELF.
    ///   - count: The count to use in the comparison.
    public convenience init(keyPath: KeyPath? = nil, countLessThanOrEqualTo value: Int) {
        if let keyPath = keyPath {
            self.init(format: "%K.@count <= %@", argumentArray: [keyPath, value])
        } else {
            self.init(format: "SELF.@count <= %@", argumentArray: [value])
        }
    }
    
    /// Returns a predicate that performs a greater than comparison on a relationship count.
    ///
    /// - Parameters:
    ///   - keyPath: The keypath of the relationship. Pass in `nil` to use SELF.
    ///   - count: The count to use in the comparison.
    public convenience init(keyPath: KeyPath? = nil, countGreaterThan value: Int) {
        if let keyPath = keyPath {
            self.init(format: "%K.@count > %@", argumentArray: [keyPath, value])
        } else {
            self.init(format: "SELF.@count > %@", argumentArray: [value])
        }
    }
    
    /// Returns a predicate that performs a greater than or equal to comparison on a relationship count.
    ///
    /// - Parameters:
    ///   - keyPath: The keypath of the relationship. Pass in `nil` to use SELF.
    ///   - count: The count to use in the comparison.
    public convenience init(keyPath: KeyPath? = nil, countGreaterThanOrEqualTo value: Int) {
        if let keyPath = keyPath {
            self.init(format: "%K.@count >= %@", argumentArray: [keyPath, value])
        } else {
            self.init(format: "SELF.@count >= %@", argumentArray: [value])
        }
    }
}

// MARK: - IN

extension NSPredicate {
    
    /// Returns a predicate that checks if a property is included in an array.
    ///
    /// - Parameters:
    ///   - keyPath: The keypath of the property. Pass in `nil` to use SELF.
    ///   - array: The array to check the value against.
    public convenience init(keyPath: KeyPath? = nil, isIncludedIn array: [Any]) {
        if let keyPath = keyPath {
            self.init(format: "%K IN %@", argumentArray: [keyPath, array])
        } else {
            self.init(format: "SELF IN %@", argumentArray: [array])
        }
    }
    
    /// Returns a predicate that checks if a property is not included in an array.
    ///
    /// - Parameters:
    ///   - keyPath: The keypath of the property. Pass in `nil` to use SELF.
    ///   - array: The array to check the value against.
    public convenience init(keyPath: KeyPath? = nil, isNotIncludedIn array: [Any]) {
        if let keyPath = keyPath {
            self.init(format: "NOT (%K IN %@)", argumentArray: [keyPath, array])
        } else {
            self.init(format: "NOT (SELF IN %@)", argumentArray: [array])
        }
    }
}

// MARK: - Strings

extension NSPredicate {
    
    /// Returns a predicate that checks if a string property begins with another string.
    ///
    /// - Parameters:
    ///   - keyPath: The keypath of the string property. Pass in `nil` to use SELF.
    ///   - string: The string to compare the property to.
    public convenience init(keyPath: KeyPath? = nil, beginsWith string: String) {
        if let keyPath = keyPath {
            self.init(format: "%K BEGINSWITH[cd] %@", argumentArray: [keyPath, string])
        } else {
            self.init(format: "SELF BEGINSWITH[cd] %@", argumentArray: [string])
        }
    }
    
    /// Returns a predicate that checks if a string property contains another string.
    ///
    /// - Parameters:
    ///   - keyPath: The keypath of the string property. Pass in `nil` to use SELF.
    ///   - string: The string to compare the property to.
    public convenience init(keyPath: KeyPath? = nil, containsString string: String) {
        if let keyPath = keyPath {
            self.init(format: "%K CONTAINS[cd] %@", argumentArray: [keyPath, string])
        } else {
            self.init(format: "SELF CONTAINS[cd] %@", argumentArray: [string])
        }
    }
    
    /// Returns a predicate that checks if a string property ends with another string.
    ///
    /// - Parameters:
    ///   - keyPath: The keypath of the string property. Pass in `nil` to use SELF.
    ///   - string: The string to compare the property to.
    public convenience init(keyPath: KeyPath? = nil, endsWith string: String) {
        if let keyPath = keyPath {
            self.init(format: "%K ENDSWITH[cd] %@", argumentArray: [keyPath, string])
        } else {
            self.init(format: "SELF ENDSWITH[cd] %@", argumentArray: [string])
        }
    }
}
