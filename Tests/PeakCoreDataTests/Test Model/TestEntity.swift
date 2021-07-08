//
//  TestEntity.swift
//  PeakCoreData
//
//  Created by David Yates on 07/12/2016.
//  Copyright © 2016 3Squared Ltd. All rights reserved.
//

import CoreData
@testable import PeakCoreData

extension TestEntity: ManagedObjectType {
    
    public static var defaultSortDescriptors: [NSSortDescriptor] {
        let sortByTitle = NSSortDescriptor(key: #keyPath(TestEntity.title),
                                           ascending: true,
                                           selector: #selector(NSString.caseInsensitiveCompare(_:)))
        return [sortByTitle]
    }
}

extension TestEntity: UniqueIdentifiable {
    public static var uniqueIDKey: String { #keyPath(TestEntity.uniqueID) }
    public var uniqueIDValue: String { uniqueID! }
}
