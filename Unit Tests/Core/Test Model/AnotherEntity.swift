//
//  AnotherEntity.swift
//  PeakCoreDataTests
//
//  Created by David Yates on 16/03/2018.
//  Copyright © 2018 3Squared Ltd. All rights reserved.
//

import Foundation

#if os(iOS)

@testable import PeakCoreData_iOS

#else

@testable import PeakCoreData_macOS

#endif

extension AnotherEntity: ManagedObjectType {
    
    public static var defaultSortDescriptors: [NSSortDescriptor] {
        let sortByTitle = NSSortDescriptor(key: #keyPath(TestEntity.title), ascending: true, selector: #selector(NSString.caseInsensitiveCompare(_:)))
        return [sortByTitle]
    }
}

extension AnotherEntity: UniqueIdentifiable {
    
    public static var uniqueIDKey: String {
        return "uniqueID"
    }
    
    public var uniqueIDValue: String {
        return uniqueID!
    }
}
