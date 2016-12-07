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
        return coreDataManager.viewContext
    }
}

public final class CoreDataManager {
    
    private let modelName: String
    private let storeType: String
    private let bundle: Bundle

    public init(modelName: String, storeType: String = NSSQLiteStoreType, bundle: Bundle = Bundle.main) {
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
    
    private var persistentStoreURL: URL {
        let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documentsDirectoryURL.appendingPathComponent(modelName + ".sqlite")
    }
    
    // MARK: - Core Data Stack
    
    private(set) public lazy var viewContext: NSManagedObjectContext = {
        if #available(iOS 10.0, *) { return self.storeContainer.viewContext }
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator
        return managedObjectContext
    }()
    
    @available(iOS 10.0, *)
    private lazy var storeContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: self.modelName, managedObjectModel: self.managedObjectModel!)
        container.persistentStoreDescriptions = self.persistentStoreDescriptions
        container.loadPersistentStores { storeDescription, error in
            guard let error = error else { return }
            fatalError("Error loading persistent stores: \(error)")
        }
        return container
    }()
    
    @available(iOS 10.0, *)
    private lazy var persistentStoreDescriptions: [NSPersistentStoreDescription] = {
        let description = NSPersistentStoreDescription(url: self.persistentStoreURL)
        description.shouldInferMappingModelAutomatically = true
        description.shouldMigrateStoreAutomatically = true
        return [description]
    }()
    
    private lazy var managedObjectModel: NSManagedObjectModel? = {
        guard let modelURL = self.bundle.url(forResource: self.modelName, withExtension: "momd") else { return nil }
        let managedObjectModel = NSManagedObjectModel(contentsOf: modelURL)
        return managedObjectModel
    }()
    
    private lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        guard let managedObjectModel = self.managedObjectModel else { return nil }
        
        let persistentStoreURL = self.persistentStoreURL
        let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        
        do {
            let options = [ NSMigratePersistentStoresAutomaticallyOption : true, NSInferMappingModelAutomaticallyOption : true ]
            try persistentStoreCoordinator.addPersistentStore(ofType: self.storeType, configurationName: nil, at: persistentStoreURL, options: options)
        } catch let error as NSError {
            fatalError("Error adding persistent store: \(error.localizedDescription)")
        }
        
        return persistentStoreCoordinator
    }()
    
    // MARK: - Public Methods
    
    public func saveChanges() {
        guard viewContext.hasChanges else { return }
        viewContext.performAndWait({
            do {
                try self.viewContext.save()
            } catch let error as NSError {
                print("Error Saving Main Context: \(error.localizedDescription)")
            }
        })
    }
    
    public func newBackgroundContext() -> NSManagedObjectContext {
        if #available(iOS 10.0, *) { return self.storeContainer.newBackgroundContext() }
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator
        return managedObjectContext
    }
    
    // MARK: - Private Helper Methods
    
    private func mergeChanges(fromContextDidSave notification: Notification) {
        guard let managedObjectContext = notification.object as? NSManagedObjectContext,
            managedObjectContext.concurrencyType == .privateQueueConcurrencyType,
            managedObjectContext.parent == nil else { return }
        
        viewContext.performAndWait {
            self.viewContext.mergeChanges(fromContextDidSave: notification)
        }
    }
}
