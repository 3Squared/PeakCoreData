//
//  TestEntity.swift
//  PeakCoreData
//
//  Created by David Yates on 07/12/2016.
//  Copyright © 2016 3Squared Ltd. All rights reserved.
//

import Foundation

#if os(iOS)

@testable import PeakCoreData_iOS

#else

@testable import PeakCoreData_macOS

#endif

extension TestEntity: ManagedObjectType {
    
    public static var defaultSortDescriptors: [NSSortDescriptor] {
        let sortByTitle = NSSortDescriptor(key: #keyPath(TestEntity.title), ascending: true, selector: #selector(NSString.caseInsensitiveCompare(_:)))
        return [sortByTitle]
    }
}

extension TestEntity: UniqueIdentifiable {
    
    public static var uniqueIDKey: String {
        return "uniqueID"
    }
    
    public var uniqueIDValue: String {
        return uniqueID!
    }
}
