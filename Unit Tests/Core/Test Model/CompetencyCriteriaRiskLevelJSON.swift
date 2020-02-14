//
//  CompetencyCriteriaRiskLevelJSON.swift
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

struct CompetencyCriteriaRiskLevelJSON: Decodable {
    let competencyCriteriaRiskLevelId: String
    
    let colour: String?
    let isDeleted: Bool
    let name: String?
    let orderIndex: Int16
}

extension CompetencyCriteriaRiskLevelJSON: UniqueIdentifiable {
    public static var uniqueIDKey: String { "competencyCriteriaRiskLevelId" }
    public var uniqueIDValue: AnyHashable { competencyCriteriaRiskLevelId }
}

extension CompetencyCriteriaRiskLevelJSON: ManagedObjectUpdatable {
    
    static var updateProperties: ((CompetencyCriteriaRiskLevelJSON, CompetencyCriteriaRiskLevel) -> Void)? = { int, mo in
        mo.title = int.name
        mo.isHidden = int.isDeleted
        mo.colorHEX = int.colour
        mo.sortOrder = int.orderIndex
    }
    
    static var updateRelationships: ((CompetencyCriteriaRiskLevelJSON, CompetencyCriteriaRiskLevel, NSManagedObjectContext, ManagedObjectCache?) -> Void)? = nil
}
