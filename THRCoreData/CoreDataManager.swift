//
//  CoreDataManager.swift
//  THRCoreData
//
//  Created by David Yates on 07/12/2016.
//  Copyright © 2016 3Squared Ltd. All rights reserved.
//

import Foundation
import CoreData

public protocol CoreDataManagerSettable: class {
    
    var coreDataManager: CoreDataManager! { get set }
}

public extension CoreDataManagerSettable {
    
    var managedObjectContext: NSManagedObjectContext {
        return coreDataManager.mainContext
    }
}

public final class CoreDataManager {
    
    enum ModelFileExtension: String {
        case bundle = "momd"
        case sqlite = "sqlite"
    }
    
    private let modelName: String
    private let storeType: StoreType
    private let bundle: Bundle
    
    /**
     Constructs a new `CoreDataManager` instance with the specified model name, store type and bundle.
     
     - parameter modelName: The name of the Core Data model.
     - parameter storeType: The store type for the Core Data model. The default is `.sqlite`, with the user's documents directory.
     - parameter bundle:    The bundle in which the model is located. The default is the main bundle.
     
     - returns: A new `CoreDataManager` instance.
     */
    public init(modelName: String, storeType: StoreType = .sqlite(defaultDirectoryURL), bundle: Bundle = .main) {
        self.modelName = modelName
        self.storeType = storeType
        self.bundle = bundle
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.NSManagedObjectContextDidSave, object: nil, queue: nil, using: {
            [weak self] notification in
            guard let strongSelf = self else { return }
            strongSelf.mergeChanges(fromContextDidSave: notification)
        })
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
    }
    
    /// The database file name for the store.
    private var databaseFilename: String {
        switch storeType {
        case .sqlite:
            return modelName + "." + ModelFileExtension.sqlite.rawValue
        default:
            return modelName
        }
    }
    
    /**
     The URL specifying the full path to the store.
     
     - note: If the store is in-memory, then this value will be `nil`.
     */
    private var storeURL: URL? {
        return storeType.storeDirectory?.appendingPathComponent(databaseFilename)
    }
    
    /// The URL of the model file in the specified `bundle`.
    private var modelURL: URL {
        guard let url = bundle.url(forResource: modelName, withExtension: ModelFileExtension.bundle.rawValue) else {
            fatalError("Error loading model URL for model named \(modelName) in bundle: \(bundle)")
        }
        return url
    }
    
    /// The managed object model for the model specified by `modelName`.
    private var managedObjectModel: NSManagedObjectModel {
        guard let model = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Error loading managed object model at url: \(modelURL)")
        }
        return model
    }
    
    /// The default persistent store options to allow automatic model migrations.
    private var defaultPersistentStoreOptions: [AnyHashable: Any] {
        return [ NSMigratePersistentStoresAutomaticallyOption : true, NSInferMappingModelAutomaticallyOption : true ]
    }

    private(set) public lazy var mainContext: NSManagedObjectContext = {
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator
        return managedObjectContext
    }()
    
    private lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        do {
            try persistentStoreCoordinator.addPersistentStore(ofType: self.storeType.type,
                                                              configurationName: nil,
                                                              at: self.storeURL,
                                                              options: self.defaultPersistentStoreOptions)
        } catch {
            fatalError("Error adding persistent store: \(error.localizedDescription)")
        }
        return persistentStoreCoordinator
    }()
    
    // MARK: - Public Methods
    
    public func saveMainContext() {
        save(context: mainContext)
    }
    
    public func save(context: NSManagedObjectContext, wait: Bool = true, completion: ((SaveResult) -> ())? = nil) {
        let block = {
            guard context.hasChanges else { return }
            do {
                try context.save()
                completion?(.success)
            } catch let error as NSError {
                print("Error saving context: \(error.localizedDescription)")
                completion?(.failure(error))
            }
        }
        wait ? context.performAndWait(block) : context.perform(block)
    }
    
    public func newBackgroundContext() -> NSManagedObjectContext {
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator
        return managedObjectContext
    }
    
    // MARK: - Private Helper Methods
    
    private func mergeChanges(fromContextDidSave notification: Notification) {
        guard let managedObjectContext = notification.object as? NSManagedObjectContext,
            managedObjectContext.concurrencyType == .privateQueueConcurrencyType,
            managedObjectContext.parent == nil else { return }
        
        mainContext.performAndWait {
            self.mainContext.mergeChanges(fromContextDidSave: notification)
        }
    }
}
