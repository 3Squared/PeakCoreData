//
//  CompetencyCriteriaRiskLevel.swift
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

extension CompetencyCriteriaRiskLevel: ManagedObjectType { }

extension CompetencyCriteriaRiskLevel: UniqueIdentifiable {
    
    public static var uniqueIDKey: String { "competencyCriteriaRiskLevelID" }
    public var uniqueIDValue: AnyHashable { competencyCriteriaRiskLevelID! }
}
