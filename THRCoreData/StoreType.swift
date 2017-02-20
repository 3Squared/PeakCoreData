//
//  Utilities.swift
//  THRCoreData
//
//  Created by David Yates on 20/02/2017.
//  Copyright © 2017 3Squared Ltd. All rights reserved.
//

import CoreData
import THRResult

public enum StoreType {
    case sqlite
    case inMemory
    
    public var value: String {
        switch self {
        case .sqlite:
            return NSSQLiteStoreType
        case .inMemory:
            return NSInMemoryStoreType
        }
    }
}
