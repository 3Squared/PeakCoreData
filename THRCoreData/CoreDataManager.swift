//
//  CoreDataManager.swift
//  THRCoreData
//
//  Created by David Yates on 07/12/2016.
//  Copyright © 2016 3Squared Ltd. All rights reserved.
//

import Foundation
import CoreData
import THRResult

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
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
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
        let context = self.createContext(withConcurrencyType: .mainQueueConcurrencyType, name: "main")
        context.persistentStoreCoordinator = self.persistentStoreCoordinator
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didReceiveMainContextDidSave(notification:)),
                                               name: NSNotification.Name.NSManagedObjectContextDidSave,
                                               object: context)
        return context
    }()
    
    private(set) public lazy var backgroundContext: NSManagedObjectContext = {
        let context = self.createContext(withConcurrencyType: .privateQueueConcurrencyType, name: "background")
        context.persistentStoreCoordinator = self.persistentStoreCoordinator
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didReceiveBackgroundContextDidSave(notification:)),
                                               name: NSNotification.Name.NSManagedObjectContextDidSave,
                                               object: context)
        return context
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
}

// MARK: - Public Methods

extension CoreDataManager {
    
    /**
     Creates a new child context with the specified `concurrencyType` and `mergePolicyType`.
     
     The parent context is either `mainContext` or `backgroundContext` dependending on the specified `concurrencyType`:
     * `.PrivateQueueConcurrencyType` will set `backgroundContext` as the parent.
     * `.MainQueueConcurrencyType` will set `mainContext` as the parent.
     
     Saving the child context will propagate changes through the parent context and then to the persistent store.
     
     - warning: Do not use `.confinementConcurrencyType` type. It is deprecated and will cause a fatal error.
     
     - parameter concurrencyType: The concurrency pattern to use. The default is `.MainQueueConcurrencyType`.
     - parameter mergePolicyType: The merge policy to use. The default is `.MergeByPropertyObjectTrumpMergePolicyType`.
     
     - returns: A new child managed object context.
     */
    public func createChildContext(withConcurrencyType concurrencyType: NSManagedObjectContextConcurrencyType = .mainQueueConcurrencyType, mergePolicyType: NSMergePolicyType = .mergeByPropertyObjectTrumpMergePolicyType) -> NSManagedObjectContext {
        let childContext = NSManagedObjectContext(concurrencyType: concurrencyType)
        
        switch concurrencyType {
        case .mainQueueConcurrencyType:
            childContext.parent = mainContext
        case .privateQueueConcurrencyType:
            childContext.parent = backgroundContext
        case .confinementConcurrencyType:
            fatalError("Error: ConfinementConcurrencyType is not supported because it is being deprecated in iOS 9.0")
        }
        
        if let name = childContext.parent?.name {
            childContext.name = name + ".child"
        }
        
        childContext.mergePolicy = NSMergePolicy(merge: mergePolicyType)

        return childContext
    }
    
    /**
     Attempts to commit unsaved changes to registered objects in the main context.
     
     - warning: This function is performed in the `perform` block on the background context's queue so is asynchronous.
     
     - parameter completion:    The closure to be executed when the save operation completes.
     */
    public func saveMainContext(withCompletion completion: SaveCompletionType? = nil) {
        save(context: mainContext, withCompletion: completion)
    }
    
    /**
     Attempts to commit unsaved changes to registered objects in the background context.
     
     - warning: This function is performed in the `perform` block on the background context's queue so is asynchronous.
     
     - parameter completion:    The closure to be executed when the save operation completes.
     */
    public func saveBackgroundContext(withCompletion completion: SaveCompletionType? = nil) {
        save(context: backgroundContext, withCompletion: completion)
    }
}

// MARK: - Private Methods

extension CoreDataManager {
    
    fileprivate func createContext(withConcurrencyType concurrencyType: NSManagedObjectContextConcurrencyType, name: String) -> NSManagedObjectContext {
        let context = NSManagedObjectContext(concurrencyType: concurrencyType)
        context.mergePolicy = NSMergePolicy(merge: .mergeByPropertyStoreTrumpMergePolicyType)
        let contextName = "THRCoreData.CoreDataManager.context."
        context.name = contextName + name
        return context
    }

    @objc
    fileprivate func didReceiveBackgroundContextDidSave(notification: Notification) {
        mainContext.perform {
            self.mainContext.mergeChanges(fromContextDidSave: notification)
        }
    }
    
    @objc
    fileprivate func didReceiveMainContextDidSave(notification: Notification) {
        backgroundContext.perform {
            self.backgroundContext.mergeChanges(fromContextDidSave: notification)
        }
    }
}
