//
//  MigrationStep.swift
//  PeakCoreData
//
//  Created by David Yates on 10/05/2019.
//  Copyright © 2019 3Squared Ltd. All rights reserved.
//

import CoreData

public final class MigrationStep {
    private let sourceModel: NSManagedObjectModel
    private let destinationModel: NSManagedObjectModel
    private let bundle: Bundle
    
    init<Version: ModelVersion>(sourceVersion: Version, destinationVersion: Version) {
        self.sourceModel = sourceVersion.managedObjectModel
        self.destinationModel = destinationVersion.managedObjectModel
        self.bundle = Version.bundle
    }
    
    func performMigration(from url: URL) -> URL {
        guard let mappingModel = mappingModel() else {
            fatalError("Failed to find a custom or inferred mapping model from \(sourceModel) to \(destinationModel)")
        }
        let manager = NSMigrationManager(sourceModel: sourceModel, destinationModel: destinationModel)
        let tempDestinationURL = URL.temporary
        
        do {
            try manager.migrateStore(from: url,
                                     sourceType: NSSQLiteStoreType,
                                     options: nil,
                                     with: mappingModel,
                                     toDestinationURL: tempDestinationURL,
                                     destinationType: NSSQLiteStoreType,
                                     destinationOptions: nil)
        } catch {
            fatalError("Failed to migrate from \(sourceModel) to \(destinationModel), error: \(error)")
        }
        
        return tempDestinationURL
    }
    
    private func mappingModel() -> NSMappingModel? {
        if let customMapping = NSMappingModel(from: [bundle], forSourceModel: sourceModel, destinationModel: destinationModel) {
            return customMapping
        }
        return try? NSMappingModel.inferredMappingModel(forSourceModel: sourceModel, destinationModel: destinationModel)
    }
}

private extension URL {
    
    static var temporary: URL {
        return URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true).appendingPathComponent(UUID().uuidString)
    }
}
