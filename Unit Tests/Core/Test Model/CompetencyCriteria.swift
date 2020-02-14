//
//  CompetencyCriteria.swift
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

extension CompetencyCriteria: ManagedObjectType { }

extension CompetencyCriteria: UniqueIdentifiable {
    public static var uniqueIDKey: String { "competencyCriteriaID" }
    public var uniqueIDValue: AnyHashable { competencyCriteriaID! }
}

extension BaseCompetencyCriteria: ManagedObjectType { }

extension BaseCompetencyCriteria: UniqueIdentifiable {
    public static var uniqueIDKey: String { "baseCompetencyCriteriaID" }
    public var uniqueIDValue: AnyHashable { baseCompetencyCriteriaID! }
}
