//
//  CompetencyElement.swift
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

extension CompetencyElement: ManagedObjectType { }

extension CompetencyElement: UniqueIdentifiable {
    
    public static var uniqueIDKey: String { "competencyElementID" }
    public var uniqueIDValue: AnyHashable { competencyElementID! }
}
