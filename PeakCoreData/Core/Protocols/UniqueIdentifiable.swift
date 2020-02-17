//
//  UniqueIdentifiable.swift
//  PeakCoreData
//
//  Created by David Yates on 07/12/2016.
//  Copyright © 2016 3Squared Ltd. All rights reserved.
//

import Foundation

public protocol UniqueIdentifiable {
    static var uniqueIDKey: String { get }
    var uniqueIDValue: AnyHashable { get }
}

public extension UniqueIdentifiable {
    
    static func uniqueID(equalTo value: AnyHashable) -> NSPredicate {
        return NSPredicate(equalTo: value, keyPath: uniqueIDKey)
    }
    
    static func anyUniqueID(equalTo value: AnyHashable) -> NSPredicate {
        return NSPredicate(anyEquals: value, keyPath: uniqueIDKey)
    }
    
    static func uniqueIDIncludedIn(ids: [AnyHashable]) -> NSPredicate {
        return NSPredicate(isIncludedIn: ids, keyPath: uniqueIDKey)
    }
}
