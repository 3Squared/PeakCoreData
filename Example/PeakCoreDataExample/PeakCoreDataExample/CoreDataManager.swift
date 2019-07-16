//
//  CoreDataManager.swift
//  PeakCoreDataExample
//
//  Created by David Yates on 13/05/2019.
//  Copyright © 2019 3Squared Ltd. All rights reserved.
//

import CoreData
import PeakCoreData

enum ExampleModelVersion: String, CaseIterable {
    case version1 = "PeakCoreDataExample"
    case version2 = "PeakCoreDataExample 2"
}

extension ExampleModelVersion: ModelVersion {

    static var current: ExampleModelVersion { return .version2 }
    static var bundle: Bundle { return Bundle(for: Event.self) }
    static var subdirectory: String { return "PeakCoreDataExample.momd" }
    
    var name: String { return rawValue }
    
    var nextVersion: ExampleModelVersion? {
        switch self {
        case .version1:
            return .version2
        case .version2:
            return nil
        }
    }
}

class CoreDataManager {
    
    static let shared = CoreDataManager()
    
    private let migrator: ProgressiveMigrator
    private let storeType: String
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "PeakCoreDataExample")
        let storeDescription = container.persistentStoreDescriptions.first
        storeDescription?.shouldInferMappingModelAutomatically = false
        storeDescription?.shouldMigrateStoreAutomatically = false
        storeDescription?.type = storeType
        return container
    }()
    
    init(storeType: String = NSSQLiteStoreType, migrator: ProgressiveMigrator = ProgressiveMigrator()) {
        self.storeType = storeType
        self.migrator = migrator
    }
    
    func setup(then completion: @escaping (NSPersistentContainer) -> ()) {
        migrateStoreIfNeeded {
            self.persistentContainer.loadPersistentStores { description, error in
                guard error == nil else {
                    fatalError("Unable to load store \(error!)")
                }
                completion(self.persistentContainer)
            }
        }
    }
    
    private func migrateStoreIfNeeded(completion: @escaping () -> Void) {
        guard let storeURL = persistentContainer.persistentStoreDescriptions.first?.url else {
            fatalError("PersistentContainer was not set up properly")
        }
        if migrator.storeRequiresMigration(at: storeURL, toVersion: ExampleModelVersion.current) {
            DispatchQueue.global(qos: .userInitiated).async {
                self.migrator.migrateStore(at: storeURL, toVersion: ExampleModelVersion.current)
                DispatchQueue.main.async(execute: completion)
            }
        } else {
            completion()
        }
    }
}

