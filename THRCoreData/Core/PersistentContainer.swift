//
//  PersistentContainer.swift
//  THRCoreData
//
//  Created by David Yates on 20/02/2017.
//  Copyright © 2017 3Squared Ltd. All rights reserved.
//

import CoreData
import THRResult

public enum SaveOutcome {
    case saved
    case noChanges
}
public typealias SetupCompletionType = (Result<PersistentStoreDescription>) -> ()
public typealias SaveCompletionType = (Result<SaveOutcome>) -> ()

/// A container that encapsulates the Core Data stack in your application.
public final class PersistentContainer {
    
    internal enum ModelFileExtension: String {
        case bundle = "momd"
        case sqlite = "sqlite"
    }
    
    /**
     The managed object context associated with the main queue. (read-only)
     
     - discussion:  This property contains a reference to the `NSManagedObjectContext` that is created and owned by the persistent container which is associated with the main queue of the application. 
     This context is created automatically as part of the initialization of the persistent container. 
     This context is configured to be generational and to automatically consume save notifications from other contexts. 
     This context is associated directly with the NSPersistentStoreCoordinator.
     */
    public let mainContext: NSManagedObjectContext
    
    /**
     The managed object context associated with a background queue. (read-only)
     
     - discussion:  This property contains a reference to the `NSManagedObjectContext` that is created and owned by the persistent container which is associated with a background queue of the application.
     This context is created automatically as part of the initialization of the persistent container.
     This context is configured to be generational and to automatically consume save notifications from other contexts.
     This context is associated directly with the NSPersistentStoreCoordinator.
     */
    public let backgroundContext: NSManagedObjectContext
    
    /**
     The persistent store description used to create the persistent stores referenced by this persistent container.
     
     - discussion:  If you want to override the type (or types) of persistent store used by the persistent container, you can set this property with a `PersistentStoreDescription` object.
     If you will be configuring a custom persistent store description, you must set this property before calling loadPersistentStores(completionHandler:).
     */
    public var persistentStoreDescription: PersistentStoreDescription?
    
    /**
     The name of this persistent container. (read-only)
     
     - discussion:  This property is passed in as part of the initialization of the persistent container.
     This name is used to locate the `NSManagedObjectModel` (if the `NSManagedObjectModel` object is not passed in as part of the initialization) and is used to name the persistent store.
    */
    public let name: String
    
    /**
     The model associated with this persistent container. (read-only)
     
     - discussion:  This property contains a reference to the `NSManagedObjectModel` object associated with this persistent container.
     */
    public let managedObjectModel: NSManagedObjectModel
    
    /**
     The persistent store coordinator associated with this persistent container. (read-only)
     
     - discussion:  When the persistent container is initialized, it creates a persistent store coordinator as part of that initialization. That persistent store coordinator is referenced in this property.
     */
    public let persistentStoreCoordinator: NSPersistentStoreCoordinator
    
    /**
     Initializes a persistent container with the given data model name.
     
     - parameter    name: The name used by the persistent container.
     
     - returns:     A persistent container initialized with the given name.
     
     - discussion:  By default, the provided name value is used to name the persistent store and is used to look up the name of the `NSManagedObjectModel` object to be used with the `PersistentContainer` object.
    */
    public convenience init(name: String) {
        guard let modelURL = Bundle.main.url(forResource: name, withExtension: ModelFileExtension.bundle.rawValue) else {
            fatalError("*** Error loading model URL for model named \(name)")
        }
        guard let model = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("*** Error loading managed object model at url: \(modelURL)")
        }
        self.init(name: name, model: model)
    }
    
    /**
     Initializes a persistent container with the given name and model.
     
     - parameter    name: The name used by the persistent container.
     - parameter    model: The managed object model to be used by the persistent container.

     - returns:     A persistent container initialized with the given name and model.
     
     - discussion:  By default, the provided name value of the container is used as the name of the persisent store associated with the container. Passing in the `NSManagedObjectModel` object overrides the lookup of the model by the provided name value.
     */
    public init(name: String, model: NSManagedObjectModel) {
        self.name = name
        self.managedObjectModel = model
        self.persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        
        let mainContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        mainContext.persistentStoreCoordinator = self.persistentStoreCoordinator
        mainContext.mergePolicy = NSMergePolicy(merge: .mergeByPropertyStoreTrumpMergePolicyType)
        mainContext.name = "THRCoreData.CoreDataManager.context.main"
        self.mainContext = mainContext
        
        let backgroundContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        backgroundContext.persistentStoreCoordinator = self.persistentStoreCoordinator
        backgroundContext.mergePolicy = NSMergePolicy(merge: .mergeByPropertyStoreTrumpMergePolicyType)
        backgroundContext.name = "THRCoreData.CoreDataManager.context.background"
        self.backgroundContext = backgroundContext
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self,
                                       selector: #selector(didReceiveMainContextDidSave(notification:)),
                                       name: NSNotification.Name.NSManagedObjectContextDidSave,
                                       object: mainContext)
        notificationCenter.addObserver(self,
                                       selector: #selector(didReceiveBackgroundContextDidSave(notification:)),
                                       name: NSNotification.Name.NSManagedObjectContextDidSave,
                                       object: backgroundContext)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    /**
     Instructs the persistent container to load the persistent stores.

     - parameter    block: Once the loading of the persistent stores has completed, this block will be executed on the calling thread.

     - discussion:  Once the persistent container has been initialized, you need to execute loadPersistentStores(completionHandler:)
     to instruct the container to load the persistent stores and complete the creation of the Core Data stack.
     Once the completion handler has fired, the stack is fully initialized and is ready for use.
    */
    public func loadPersistentStores(completionHandler block: @escaping SetupCompletionType = { _ in }) {
        let description: PersistentStoreDescription
        if let persistentStoreDescription = persistentStoreDescription {
            description = persistentStoreDescription
        } else {
            let storeURL = defaultDirectoryURL().appendingPathComponent(name + ModelFileExtension.sqlite.rawValue)
            description = PersistentStoreDescription(url: storeURL)
        }
        let isAsync = description.shouldAddStoreAsynchronously
        let creationClosure = {
            do {
                try self.persistentStoreCoordinator.addPersistentStore(ofType: description.type.value,
                                                                       configurationName: nil,
                                                                       at: description.url,
                                                                       options: description.options)
                if isAsync {
                    DispatchQueue.main.async {
                        block(.success(description))
                    }
                } else {
                    block(.success(description))
                }
            } catch {
                if isAsync {
                    DispatchQueue.main.async {
                        block(.failure(error))
                    }
                } else {
                    block(.failure(error))
                }
            }
        }
        
        if isAsync {
            let queue = DispatchQueue.global(qos: .userInitiated)
            queue.async(execute: creationClosure)
        } else {
            creationClosure()
        }
    }
}

extension PersistentContainer {
    
    /**
     Creates the default directory for the persistent stores on the current platform.
     
     - return:      An NSURL that references the directory in which the persistent store will be located or are currently located.
    */
    public func defaultDirectoryURL() -> URL {
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
    
    /**
     Creates a new child context with the specified `concurrencyType` and `mergePolicyType`.
     
     The parent context is either `mainContext` or `backgroundContext` dependending on the specified `concurrencyType`:
     * `.PrivateQueueConcurrencyType` will set `backgroundContext` as the parent.
     * `.MainQueueConcurrencyType` will set `mainContext` as the parent.
     
     Saving the child context will propagate changes through the parent context and then to the persistent store.
     
     - warning:     Do not use `.confinementConcurrencyType` type. It is deprecated and will cause a fatal error.
     
     - parameter    concurrencyType: The concurrency pattern to use. The default is `.MainQueueConcurrencyType`.
     - parameter    mergePolicyType: The merge policy to use. The default is `.MergeByPropertyObjectTrumpMergePolicyType`.
     
     - returns:     A new child managed object context.
     */
    public func createChildContext(withConcurrencyType concurrencyType: NSManagedObjectContextConcurrencyType = .mainQueueConcurrencyType, mergePolicyType: NSMergePolicyType = .mergeByPropertyObjectTrumpMergePolicyType) -> NSManagedObjectContext {
        let childContext = NSManagedObjectContext(concurrencyType: concurrencyType)
        
        switch concurrencyType {
        case .mainQueueConcurrencyType:
            childContext.parent = mainContext
        case .privateQueueConcurrencyType:
            childContext.parent = backgroundContext
        case .confinementConcurrencyType:
            fatalError("*** confinementConcurrencyType is not supported because it is being deprecated in iOS 9.0")
        }
        
        if let name = childContext.parent?.name {
            childContext.name = name + ".child"
        }
        
        childContext.mergePolicy = NSMergePolicy(merge: mergePolicyType)
        
        return childContext
    }
    
    /**
     Attempts to commit unsaved changes to registered objects in the specified context.
     
     - warning:     This function is performed in the `perform` block on the background context's queue so is asynchronous.
     
     - note:        If the context you pass in is a child context, it will automatically propagate changes through the parent context and then to the persistent store.
     
     - parameter    context:       The managed object context to save.
     - parameter    completion:    The closure to be executed when the save operation completes.
     */
    public func save(context: NSManagedObjectContext, withCompletion completion: SaveCompletionType? = nil) {
        context.perform {
            guard context.hasChanges else {
                completion?(.success(.noChanges))
                return
            }
            do {
                try context.save()
                if let parentContext = context.parent {
                    self.save(context: parentContext, withCompletion: completion)
                } else {
                    completion?(.success(.saved))
                }
            } catch let error as NSError {
                print("Error saving context: \(error.localizedDescription)")
                completion?(.failure(error))
            }
        }
    }
    
    /**
     Attempts to commit unsaved changes to registered objects in the main context.
     
     - warning:     This function is performed in the `perform` block on the background context's queue so is asynchronous.
     
     - parameter    completion: The closure to be executed when the save operation completes.
     */
    public func saveMainContext(withCompletion completion: SaveCompletionType? = nil) {
        save(context: mainContext, withCompletion: completion)
    }
    
    /**
     Attempts to commit unsaved changes to registered objects in the background context.
     
     - warning:     This function is performed in the `perform` block on the background context's queue so is asynchronous.
     
     - parameter    completion: The closure to be executed when the save operation completes.
     */
    public func saveBackgroundContext(withCompletion completion: SaveCompletionType? = nil) {
        save(context: backgroundContext, withCompletion: completion)
    }
}

// MARK: - Private Methods

extension PersistentContainer {

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