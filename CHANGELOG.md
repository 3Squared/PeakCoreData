# CHANGELOG

The changelog for `THRCoreData`.

--------------------------------------

2.1.0
-----

- Change `FetchedChange` to `ChangeObserver`.
- Change `ManagedObjectChangeObserver` to `ManagedObjectObserver`.
- Make sure `ChangeObserver` and `ManagedObjectObserver` change blocks are called on initialisation.

2.0.4
-----

- Makes names of parameters more consistent.

2.0.3
-----

- Replace fatal error with return when updating cell.

2.0.2
-----

- Guard against weak self in process update blocks.

2.0.1
-----

- Hand responsibility to call performFetch() to user of `FetchedTableViewDataSource` and `FetchedCollectionViewDataSource`.

2.0.0
-----

- Add `ManagedObjectChangeObserver` to track changes to a specific `ManagedObject`
- Add `FetchedCount` to track counts of a `FetchRequest`
- Add `FetchedCollection` to wrap a `FetchedResultsController` as a collection
- Add `CoreDataChangesetOperation` base class, for operations producing a changeset
- Remove `PersistentContainer` in favour of Apple's implementation
- Simplify setup of `FetchedTableViewDataSource` and `FetchedCollectionViewDataSource`
- Modernise naming of parameters throughout

1.0.1
-----

- Makes the `CoreDataSingleImportOperation` open so it can actually be used.


1.0.0
-----

- Removes saving from PersistentContainer.
- Removes background context from PersistentContainer and adds a method for creating a new background context.
- Removes ability to load store asynchronously.
- Removes THRNetwork as a subspec.
- Removes Updatable and replaces with ManagedObjectUpdatable. Codable objects are now responsible for updating the managed object (used to be the other way around).
- The `CoreDataOperation` now takes a target context rather than the persistent container.
- The `CoreDataImportOperation` is renamed to `CoreDataBatchImportOperation` and have added a `CoreDataSingleImportOperation` to handle importing a single object.

0.4.1
-----

- Updates THRNetwork and THROperations to latest versions

0.4.0
-----

- Adds a CoreDataImportOperation in a separate subspec
- Adds a default block to loadPersistentStore() method
- Changes completeAndSave() to finishAndSave()


0.3.0
-----

- Refactored stack to more closely resemble Apple's `NSPersistentContainer` and `NSPersistentStoreDescription`.
- Now possible to add persistent stores asynchronously.
- Update CoreDataOperation to use latest version of THROperation.
- Increased documentation and unit test coverage.


0.2.4
-----

- Adds indexPath(forObject:) method.
- Makes property names more consistent in places.


0.2.3
-----

- Adds a simple example project to show the framework in action.


0.2.2
-----

- Adds ability to show an empty view in the collection view when there are zero items.


0.2.1
-----

- Adds ability to show an empty view in the table view when there are zero items.
