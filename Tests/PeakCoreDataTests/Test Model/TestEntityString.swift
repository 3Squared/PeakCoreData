//
//  TestEntityString.swift
//  PeakCoreData
//
//  Created by David Yates on 07/12/2016.
//  Copyright © 2016 3Squared Ltd. All rights reserved.
//

import CoreData
@testable import PeakCoreData

extension TestEntityString: ManagedObjectType {
    
    public static var defaultSortDescriptors: [NSSortDescriptor] {
        let sortByTitle = NSSortDescriptor(key: #keyPath(TestEntityString.title),
                                           ascending: true,
                                           selector: #selector(NSString.caseInsensitiveCompare(_:)))
        return [sortByTitle]
    }
}

extension TestEntityString: UniqueIdentifiable {
    public static var uniqueIDKey: String { #keyPath(TestEntityString.uniqueID) }
    public var uniqueIDValue: String { uniqueID! }
}
