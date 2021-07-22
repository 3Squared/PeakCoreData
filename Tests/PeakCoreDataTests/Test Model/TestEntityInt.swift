//
//  TestEntityInt.swift
//  PeakCoreDataTests
//
//  Created by David Yates on 16/03/2018.
//  Copyright © 2018 3Squared Ltd. All rights reserved.
//

import CoreData
@testable import PeakCoreData

extension TestEntityInt: ManagedObjectType {
    
    public static var defaultSortDescriptors: [NSSortDescriptor] {
        let sortByIndex = NSSortDescriptor(key: uniqueIDKey,
                                           ascending: true)
        return [sortByIndex]
    }
}

extension TestEntityInt: UniqueIdentifiable {
    public static var uniqueIDKey: String { #keyPath(TestEntityInt.uniqueID) }
    public var uniqueIDValue: Int32 { uniqueID }
}
