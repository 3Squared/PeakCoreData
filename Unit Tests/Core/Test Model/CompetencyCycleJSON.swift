//
//  CompetencyCycleJSON.swift
//  PeakCoreData
//
//  Created by David Yates on 14/02/2020.
//  Copyright © 2020 3Squared Ltd. All rights reserved.
//

import CoreData

#if os(iOS)

@testable import PeakCoreData_iOS

#else

@testable import PeakCoreData_macOS

#endif

struct CompetencyCycleJSON: Decodable, Hashable {
    let competencyCycleId: String
    
    let isArchived: Bool
    let isDeleted: Bool
    let name: String?
    
    // Relationships
    let companyRoleId: String
}

extension CompetencyCycleJSON: UniqueIdentifiable {
    public static var uniqueIDKey: String { "competencyCycleId" }
    public var uniqueIDValue: AnyHashable { competencyCycleId }
}

extension CompetencyCycleJSON: ManagedObjectUpdatable {
    
    typealias ManagedObject = CompetencyCycle
    
    static var updateProperties: ((CompetencyCycleJSON, CompetencyCycle) -> Void)? = { int, mo in
        mo.title = int.name
        mo.isHidden = int.isDeleted
        mo.isArchived = int.isArchived
    }
    
    static var updateRelationships: ((CompetencyCycleJSON, CompetencyCycle, NSManagedObjectContext, ManagedObjectCache?) -> Void)? = nil
}
