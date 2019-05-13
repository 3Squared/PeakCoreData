//
//  Migrator.swift
//  PeakCoreData
//
//  Created by David Yates on 10/05/2019.
//  Copyright © 2019 3Squared Ltd. All rights reserved.
//

import CoreData

public class ProgressiveMigrator {
    
    public func storeRequiresMigration<Version: ModelVersion>(at storeURL: URL, toVersion version: Version) -> Bool {
        guard let metadata = NSPersistentStoreCoordinator.metadata(at: storeURL) else { return false }
        return Version.compatibleVersion(for: metadata) != version
    }
    
    public func migrateStore<Version: ModelVersion>(at storeURL: URL, toVersion destinationVersion: Version) {
        forceWALCheckpointingForStore(at: storeURL, bundle: Version.bundle)
        
        let migrationSteps = migrationStepsForStore(at: storeURL, toVersion: destinationVersion)
        var currentURL = storeURL
        
        migrationSteps.forEach { step in
            let tempDestinationURL = step.performMigration(from: currentURL)
            
            if currentURL != storeURL {
                NSPersistentStoreCoordinator.destroyStore(at: currentURL)
            }
            
            currentURL = tempDestinationURL
        }
        
        NSPersistentStoreCoordinator.replaceStore(at: storeURL, withStoreAt: currentURL)
        
        if currentURL != storeURL {
            NSPersistentStoreCoordinator.destroyStore(at: currentURL)
        }
    }
    
    private func migrationStepsForStore<Version: ModelVersion>(at storeURL: URL, toVersion destinationVersion: Version) -> [MigrationStep] {
        guard
            let metadata = NSPersistentStoreCoordinator.metadata(at: storeURL),
            let sourceVersion = Version.compatibleVersion(for: metadata) else { fatalError("Unknown store version at URL \(storeURL)") }
        
        return migrationSteps(from: sourceVersion, to: destinationVersion)
    }
    
    private func migrationSteps<Version: ModelVersion>(from sourceVersion: Version, to destinationVersion: Version) -> [MigrationStep] {
        var migrationSteps: [MigrationStep] = []
        var currentVersion = sourceVersion

        while currentVersion != destinationVersion, let nextVersion = currentVersion.nextVersion {
            let migrationStep = MigrationStep(sourceVersion: currentVersion, destinationVersion: nextVersion)
            migrationSteps.append(migrationStep)
            currentVersion = nextVersion
        }
        return migrationSteps
    }
    
    private func forceWALCheckpointingForStore(at storeURL: URL, bundle: Bundle) {
        guard
            let metadata = NSPersistentStoreCoordinator.metadata(at: storeURL),
            let currentModel = NSManagedObjectModel.mergedModel(from: [bundle], forStoreMetadata: metadata) else { return }
        
        do {
            let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: currentModel)
            let options = [NSSQLitePragmasOption: ["journal_mode": "DELETE"]]
            let store = persistentStoreCoordinator.addPersistentStore(at: storeURL, options: options)
            try persistentStoreCoordinator.remove(store)
        } catch {
            fatalError("Failed to force WAL checkpointing, error: \(error)")
        }
    }
}

private extension NSPersistentStoreCoordinator {
    
    static func destroyStore(at storeURL: URL) {
        do {
            let psc = NSPersistentStoreCoordinator(managedObjectModel: NSManagedObjectModel())
            try psc.destroyPersistentStore(at: storeURL, ofType: NSSQLiteStoreType, options: nil)
        } catch let error {
            fatalError("Failed to destroy persistent store at \(storeURL), error: \(error)")
        }
    }
    
    static func replaceStore(at targetURL: URL, withStoreAt sourceURL: URL) {
        do {
            let psc = NSPersistentStoreCoordinator(managedObjectModel: NSManagedObjectModel())
            try psc.replacePersistentStore(at: targetURL, destinationOptions: nil, withPersistentStoreFrom: sourceURL, sourceOptions: nil, ofType: NSSQLiteStoreType)
        } catch let error {
            fatalError("Failed to replace persistent store at \(targetURL) with \(sourceURL), error: \(error)")
        }
    }
    
    static func metadata(at storeURL: URL) -> [String : Any]?  {
        return try? NSPersistentStoreCoordinator.metadataForPersistentStore(ofType: NSSQLiteStoreType, at: storeURL, options: nil)
    }
    
    func addPersistentStore(at storeURL: URL, options: [AnyHashable : Any]) -> NSPersistentStore {
        do {
            return try addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: options)
        } catch {
            fatalError("Failed to add persistent store to coordinator, error: \(error)")
        }
    }
}
