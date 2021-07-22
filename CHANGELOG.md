# CHANGELOG

The changelog for `PeakCoreData`.

--------------------------------------
5.2.0
-----

- Adds `associatedtype` to `UniqueIdentifable` so integrers and UUIDs can be used as unique identifiers.

5.1.1
-----

- Makes persistent container public on `CoreDataOperation`.

5.1.0
-----

- Replaces Cocoapods with Swift Package Manager.
- Makes names of some predicates clearer.
- Adds a `stringNotEqualTo` predicate.

5.0.0
-----

- Drops support for iOS 10.
- Adds operations for performing `NSBatchUpdateRequest` and `NSBatchDeleteRequest`.
- The Import operations can now be initialised with a `ManagedObjectCache`.
- Some initialisers have been updated to follow Swift guidelines for parameter naming, which means this release has breaking changes.


4.1.0
-----

- Adds a `Cache` and `ManagedObjectCache` for improved performance on batch insert / update.

4.0.0
-----

- Add macOS support.
- Add method on `NSManagedObjectContext` that batch deletes all objects in all entities. Note: changes from the batch delete will no longer be automatically merged in to passed in context. There is now a new property on all batch delete methods `mergeContexts` that lets you pass in an array of contexts you want the changes merged in to.
- Add more `NSPredicate` initialisers and unit tests.

3.4.0
-----

- Add detailed progress to batch imports.

3.3.0
-----

- Add methods for returning the first objects matching a predicate.
- Add a `performAndWait` block that allows a return type.
- Add operation for converting `NSManagedObject` to an intermediate type.

3.2.0
-----

- Update to Swift 5.

3.1.0
-----

- Add helper `NSPredicate` initialisers.

3.0.2
-----

- Remove unused files.
- Move method for returning cell identifier to data source delegate.

3.0.1
-----

- Fix source url in podspec.

3.0.0
-----

- Improvements to `FetchedCollectionViewDataSource` to allow supplementary views and moving of items.
- Make sure cells are also updated when moved.
- Remove `Collection` conformance in `FetchedCollection` (this was causing performance issues).
- Improvements to readme.

2.2.1
-----

- Add a `saveViewContext` method to `PersistentContainerSettable` protocol.

2.2.0
-----

- Remove `fetchRequest` and always sort by the `defaultSortDescriptor`.

2.1.5
-----

- Call `onChange` method when set on `FetchedCollection`.

2.1.4
-----

- Make sure save is called on context's thread.

2.1.3
-----

- Remove retain cycles.

2.1.2
-----

- Bump minimum deployment to 10.0
- Update `THROperations` and `THRResult`

2.1.1
-----

- Allow `OnChange` closure to be set independently of `startObserving()` call.

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
