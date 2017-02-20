//
//  Utilities.swift
//  THRCoreData
//
//  Created by David Yates on 20/02/2017.
//  Copyright © 2017 3Squared Ltd. All rights reserved.
//

import CoreData
import THRResult

public typealias SetupCompletionType = (Result<PersistentStoreDescription>) -> ()
public typealias SaveCompletionType = (Result<SaveOutcome>) -> ()
public typealias PersistentStoreOptions = [AnyHashable: Any]

internal var migrateStoreOptions: PersistentStoreOptions {
    return [
        NSMigratePersistentStoresAutomaticallyOption: true,
        NSInferMappingModelAutomaticallyOption: true
    ]
}

public var defaultDirectoryURL: URL {
    let searchPathDirectory = FileManager.SearchPathDirectory.documentDirectory
    
    do {
        return try FileManager.default.url(for: searchPathDirectory,
                                           in: .userDomainMask,
                                           appropriateFor: nil,
                                           create: true)
    } catch {
        fatalError("*** Error finding default directory: \(error)")
    }
}

public enum ModelFileExtension: String {
    case bundle = "momd"
    case sqlite = "sqlite"
}

public enum SaveOutcome {
    case saved
    case noChanges
}

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
