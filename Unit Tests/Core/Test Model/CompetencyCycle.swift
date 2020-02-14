//
//  CompetencyCycle.swift
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

extension CompetencyCycle: ManagedObjectType { }

extension CompetencyCycle: UniqueIdentifiable {
    
    public static var uniqueIDKey: String { "competencyCycleID" }
    public var uniqueIDValue: AnyHashable { competencyCycleID! }
}

