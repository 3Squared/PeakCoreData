//
//  CompetencyElementJSON.swift
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

struct CompetencyElementJSON: Decodable {
    let competencyElementId: String
    
    let isDeleted: Bool
    let name: String?
    let orderIndex: Int16
    let versionNo: Int16
    
    // Relationships
    let competencyCriteria: [CompetencyElementJSON.CompetencyCriteriaJSON]?
    let competencyUnitId: String
    let referenceId: String
    
    struct CompetencyCriteriaJSON: Decodable {
        let competencyCriteriaId: String
        let isDeleted: Bool?
        let isRemoved: Bool?
    }
}

extension CompetencyElementJSON: UniqueIdentifiable {
    public static var uniqueIDKey: String { "competencyElementId" }
    public var uniqueIDValue: AnyHashable { competencyElementId }
}

extension CompetencyElementJSON: ManagedObjectUpdatable {
    typealias ManagedObject = CompetencyElement
    
    static var updateProperties: ((CompetencyElementJSON, CompetencyElement) -> Void)? = { int, mo in
        mo.title = int.name
        mo.isHidden = int.isDeleted
        mo.sortOrder = int.orderIndex
        mo.version = int.versionNo
    }
    
    static var updateRelationships: ((CompetencyElementJSON, CompetencyElement, NSManagedObjectContext, ManagedObjectCache?) -> Void)? = nil
}
