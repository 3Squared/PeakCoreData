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
    public convenience init(equals value: Any?, keyPath: KeyPath? = nil) {
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
    public convenience init(doesNotEqual value: Any?, keyPath: KeyPath? = nil) {
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
    public convenience init(lessThan value: Any, keyPath: KeyPath? = nil) {
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
    public convenience init(lessThanOrEqualTo value: Any, keyPath: KeyPath? = nil) {
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
    public convenience init(greaterThan value: Any, keyPath: KeyPath? = nil) {
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
    public convenience init(greaterThanOrEqualTo value: Any, keyPath: KeyPath? = nil) {
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
    public convenience init(countEquals count: Int, keyPath: KeyPath? = nil) {
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
    public convenience init(countDoesNotEqual count: Int, keyPath: KeyPath? = nil) {
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
    public convenience init(countLessThan value: Int, keyPath: KeyPath? = nil) {
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
    public convenience init(countLessThanOrEqualTo value: Int, keyPath: KeyPath? = nil) {
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
    public convenience init(countGreaterThan value: Int, keyPath: KeyPath? = nil) {
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
    public convenience init(countGreaterThanOrEqualTo value: Int, keyPath: KeyPath? = nil) {
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
    public convenience init(isIncludedIn array: [Any], keyPath: KeyPath? = nil) {
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
    public convenience init(isNotIncludedIn array: [Any], keyPath: KeyPath? = nil) {
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
    public convenience init(beginsWith string: String, keyPath: KeyPath? = nil) {
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
    public convenience init(containsString string: String, keyPath: KeyPath? = nil) {
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
    public convenience init(endsWith string: String, keyPath: KeyPath? = nil) {
        if let keyPath = keyPath {
            self.init(format: "%K ENDSWITH[cd] %@", argumentArray: [keyPath, string])
        } else {
            self.init(format: "SELF ENDSWITH[cd] %@", argumentArray: [string])
        }
    }
}
