//
//  StoreType.swift
//  THRCoreData
//
//  Created by David Yates on 08/12/2016.
//  Copyright © 2016 3Squared Ltd. All rights reserved.
//

import Foundation
import CoreData

public enum StoreType {
    case sqlite(URL)
    case binary(URL)
    case inMemory
    
    public var type: String {
        switch self {
        case .sqlite:
            return NSSQLiteStoreType
        case .binary:
            return NSBinaryStoreType
        case .inMemory:
            return NSInMemoryStoreType
        }
    }

    public var storeDirectory: URL? {
        switch self {
        case let .sqlite(url):
            return url
        case let .binary(url):
            return url
        case .inMemory:
            return nil
        }
    }
}
