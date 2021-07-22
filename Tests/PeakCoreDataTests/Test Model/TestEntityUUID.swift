//
//  TestEntityUUID.swift
//  PeakCoreDataTests
//
//  Created by David Yates on 09/07/2021.
//  Copyright © 2021 3Squared Ltd. All rights reserved.
//

import CoreData
@testable import PeakCoreData

extension TestEntityUUID: ManagedObjectType {
    
    public static var defaultSortDescriptors: [NSSortDescriptor] {
        let sortByTitle = NSSortDescriptor(key: #keyPath(TestEntityString.title),
                                           ascending: true,
                                           selector: #selector(NSString.caseInsensitiveCompare(_:)))
        return [sortByTitle]
    }
}

extension TestEntityUUID: UniqueIdentifiable {
    public static var uniqueIDKey: String { #keyPath(TestEntityUUID.uniqueID) }
    public var uniqueIDValue: UUID { uniqueID! }
}
