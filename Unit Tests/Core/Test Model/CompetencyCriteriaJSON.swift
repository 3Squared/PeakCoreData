//
//  CompetencyCriteriaJSON.swift
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

struct CompetencyCriteriaJSON: Decodable {
    let competencyCriteriaId: String
    
    let isDeleted: Bool
    let orderIndex: Int16
    let title: String?
    let versionNo: Int16
    
    // Relationships
    let competencyCriteriaRiskLevelId: String
    let competencyCycles: [CompetencyCriteriaJSON.CompetencyCycleJSON]?
    let competencyElementId: String
    let referenceId: String
    
    struct CompetencyCycleJSON: Decodable {
        let competencyCycleId: String
        let isRemoved: Bool
    }
}

extension CompetencyCriteriaJSON: UniqueIdentifiable {
    public static var uniqueIDKey: String { "competencyCriteriaId" }
    public var uniqueIDValue: AnyHashable { competencyCriteriaId }
}

extension CompetencyCriteriaJSON: ManagedObjectUpdatable {
    
    typealias ManagedObject = CompetencyCriteria
    
    static var updateProperties: ((CompetencyCriteriaJSON, CompetencyCriteria) -> Void)? = { int, mo in
        mo.title = int.title
        mo.isHidden = int.isDeleted
        mo.sortOrder = int.orderIndex
        mo.version = int.versionNo
    }
    
    static var updateRelationships: ((CompetencyCriteriaJSON, CompetencyCriteria, NSManagedObjectContext, ManagedObjectCache?) -> Void)? = { int, mo, context, cache in
        mo.baseCompetencyCriteria = BaseCompetencyCriteria.fetchOrInsertObject(with: int.referenceId, in: context, with: cache)
        mo.competencyElement = CompetencyElement.fetchOrInsertObject(with: int.competencyElementId, in: context, with: cache)
        mo.competencyCriteriaRiskLevel = CompetencyCriteriaRiskLevel.fetchOrInsertObject(with: int.competencyCriteriaRiskLevelId, in: context, with: cache)
        
        if let competencyCycles = int.competencyCycles {
            CompetencyCycle.insertOrUpdate(intermediates: competencyCycles, in: context, with: cache) { (intermediate, competencyCycle) in
                if intermediate.isRemoved {
                    mo.removeFromCompetencyCycles(competencyCycle)
                } else {
                    mo.addToCompetencyCycles(competencyCycle)
                }
            }
        }
    }
}

extension CompetencyCriteriaJSON.CompetencyCycleJSON: UniqueIdentifiable, Hashable {
    public static var uniqueIDKey: String { "competencyCycleId" }
    public var uniqueIDValue: AnyHashable { competencyCycleId }
}
