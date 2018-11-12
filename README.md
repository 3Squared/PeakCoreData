# PeakCoreData

Lightweight Swift Core Data helper to reduce boilerplate code.

## Installation

PeakCoreData is available through [CocoaPods](http://cocoapods.org). To install it, simply add the following line to your Podfile:

```ruby
pod 'PeakCoreData'
```

## Observers

### ManagedObjectObserver

### Count Observer


## Fetched Data Sources

### FetchedCollection

### FetchedCollectionViewDataSource & FetchedTableViewDataSource

These classes take care of the boiler-plate code needed to use a `NSFetchedResultsController` with a `UITableView` or `UICollectionView`. See the example project for examples of these classes in action.

## Operations

### CoreDataOperation

`CoreDataOperation` is a simple concurrent `Operation` subclass that can be used to perform core data tasks on a background thread. To use, simply subclass `CoreDataOperation` then override `performWork(in context: NSManagedObjectContext)`

* To finish the operation you must call `saveAndFinish()`. This will save the child and parent contexts and ensure changes are merged in to the main context.
* `CoreDataOperation` conforms to `ProducesResult` and so can be used to produce a `Result`.

### CoreDataChangesetOperation

### CoreDataBatchImportOperation & CoreDataSingleImportOperation

## Protocols

### ManagedObjectType and UniqueIdentifiable

To give your `NSManagedObject` subclasses access to a range of helper methods for inserting, deleting, fetching and counting, simply make them conform to the `ManagedObjectType` and `UniqueIdentifiable` protocols.

### PersistentContainerSettable

Each view controller that needs access to the `NSPersistentContainer` should conform to `PersistentContainerSettable`. Conforming to this protocol gives you easy access to the `viewContext` and a method for saving the `viewContext`. It also your `NSPersistentContainer` to be passed around more easily in `prepare(for:sender:)`. For example:

```Swift
override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
if let controller = segue.destination as? PersistentContainerSettable {
controller.persistentContainer = persistentContainer
}
if let navController = segue.destination as? UINavigationController, let controller = navController.topViewController as? PersistentContainerSettable {
controller.persistentContainer = persistentContainer
}
}

```
