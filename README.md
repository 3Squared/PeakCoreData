# PeakCoreData

Lightweight Swift Core Data helper to reduce boilerplate code.

## Installation

PeakCoreData is available through [CocoaPods](http://cocoapods.org). To install it, simply add the following line to your Podfile:

```ruby
pod 'PeakCoreData'
```

## Usage

### PersistentContainer

`PersistentContainer` is a container that encapsulates the Core Data stack in your application and works in a similar way to `NSPersistentContainer`. It is recommemded that you initialise the `PersistentContainer`in your `AppDelegate` then pass it on to your initial view controller.

```Swift
let persistentContainer = PersistentContainer(name: "PeakCoreDataExample")
persistentContainer.loadPersistentStores()
```

### PersistentStoreDescription

Similar to `NSPersistentStoreDescription`, a `PersistentStoreDescription` object can be used to customise the way the persistent store is loaded. This includes options to customise the store url, store type (`NSSQLiteStoreType`, `NSInMemoryStoreType`), whether the store should be loaded synchronously or asychronously and whether the store should migrate automatically. This should be initialised and set on a `PersistentContainer` before `loadPersistentStores()` is called. For example:

```Swift
let persistentContainer = PersistentContainer(name: "PeakCoreDataExample")
var storeDescription = PersistentStoreDescription(url: storeURL)
storeDescription.type = .inMemory
persistentContainer.persistentStoreDescription = storeDescription
```

### PersistentContainerSettable

Each view controller that needs access to the `PersistentContainer` should conform to `PersistentContainerSettable`, which allows it to be passed around more easily in `prepare(for:sender:)`. For example:

```Swift
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? PersistentContainerSettable {
            controller.coreDataManager = coreDataManager
        }
        if let navController = segue.destination as? UINavigationController, let controller = navController.topViewController as? PersistentContainerSettable {
            controller.coreDataManager = coreDataManager
        }
    }

```

### NSManagedObjectContexts

The `PersistentContainer` creates and manages two `NSManagedObjectContext` instances:

1. `mainContext` is initialised with concurrency type `NSMainQueueConcurrencyType` and so should only be used while on the main thread. This context can be saved using the `saveMainContext()` method and changes are automatically merged in to the background context.
2. `backgroundContext` is initialised with concurrency type `NSPrivateQueueConcurrencyType` and so is designed to perform work off the main thread. This context can be saved using the `saveBackgroundContext()` method and changes are automatically merged in to the main context.

The `createChildContext(withConcurrencyType:mergePolicyType:)` method creates a new child context with the specified `concurrencyType` and `mergePolicyType`. The parent context is either `mainContext` or `backgroundContext` depending on the specified `concurrencyType`:

* `.PrivateQueueConcurrencyType` will set `backgroundContext` as the parent.
* `.MainQueueConcurrencyType` will set `mainContext` as the parent.

These child contexts should be saved using the `save(context:withCompletion:)` method. Saving the child context will propagate changes through the parent context and then to the persistent store.

### Saving

As well as the `saveMainContext()` and `saveBackgroundContext()` methods, there is a general method for saving any context (`save(context:withCompletion:)`). **Please not that this method is asynchronous**. Any code that is reliant on the save being complete should be passed to the save method in the optional completion block.

### Inserting, Fetching, Deleting and Counting

To give your `NSManagedObject` subclasses access to a range of helper methods for inserting, deleting, fetching and counting, simply make them conform to the `ManagedObjectType` and `UniqueIdentifiable` protocols.
	
### CoreDataOperation

`CoreDataOperation` is a simple concurrent `Operation` subclass that can be used to perform core data tasks on a background thread. To use, simply subclass `CoreDataOperation` then override `performWork(inContext context: NSManagedObjectContext)`

* A child context of the `backgroundContext` is made for each operation. All work is done on this context.
* To finish the operation you must call `finishAndSave()`. This will save the child and parent contexts and ensure changes are merged in to the main context.
* `CoreDataOperation` conforms to `ProducesResult` and so can be used to produce a `Result`.


### NSFetchedResultsController helper classes

These classes take care of the boiler-plate code needed to use a `NSFetchedResultsController` with a `UITableView` or `UICollectionView`. See the example project for examples of these classes in action.
