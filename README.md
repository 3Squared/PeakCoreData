# THRCoreData

Swift framework that makes working with Core Data easier and helps DRY-up your code. Provides convenience methods and classes for working in a multi-threaded environment with `NSManagedObject`s and `NSManagedObjectContext`s. Codifies some good practises for importing large data sets efficiently.

## Installation

THRCoreData is available through [CocoaPods](http://cocoapods.org). To install it, simply add the following line to your Podfile:

```ruby
pod 'THRCoreData'
```

## Usage

### PersistentContainer

`PersistentContainer` works in a similar way to `NSPersistentContainer` in that it sets up and manages your core data stack. 

You should only ever use a single `CoreDataManager` as it maintains the persistent store coordinator instance for your Core Data stack. It is recommended you create it in your AppDelegate and then pass it to your initial view controller.

```
import THRCoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CoreDataManagerSettable {
        
    var window: UIWindow?
    var coreDataManager: CoreDataManager!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // Setup core data manager / sync manager
        
        coreDataManager = CoreDataManager(modelName: "MODEL_NAME")

        // Pass core data manager to initial view controller
        
        guard let viewController = window?.rootViewController as? CoreDataManagerSettable else { fatalError("Wrong initial view controller type") }

        viewController.coreDataManager = coreDataManager
        
        return true
    }
}
```

The `CoreDataManager` initialiser can take two additional properties: 

* `StoreType`: This is an `enum` that encapsulates the three different model types `NSSQLiteStoreType`, `NSBinaryStoreType` and `NSInMemoryStoreType`. This is set to `NSSQLiteStoreType` by default. Note: If you are writing unit tests that interact with Core Data, then a context manager with `NSInMemoryStoreType` is useful as changes are not persisted between test suite runs, and side effects from your production SQLite database do not contaminate your tests.
* `Bundle`: The `Bundle` that contains the model file. This is set to `.main` by default, but it is useful to be able to specify the specific `Bundle` when using the `CoreDataManager` in unit tests.

The `CoreDataManager` creates and manages two `NSManagedObjectContext` instances:

### Main Context

The main context is initialised with `NSMainQueueConcurrencyType`and should therefore only be used while on the main thread. Failure to use the main context on the main thread will result inconsistent behaviour and possible crashes. This context can be saved using the `saveMainContext()` method. When the main context is saved, the changes are automatically merged in to the background context.

### Background Context

The background context is initialised with `NSPrivateQueueConcurrencyType` and so is designed to perform Core Data work off the main thread. This context can be saved using the `saveBackgroundContext()` method. When the backgound context is saved, the changes are automatically merged in to the main context.

### Child Contexts

The `createChildContext(withConcurrencyType:mergePolicyType:)` method creates a new child context with the specified `concurrencyType` and `mergePolicyType`. The parent context is either `mainContext` or `backgroundContext` depending on the specified `concurrencyType`:

* `.PrivateQueueConcurrencyType` will set `backgroundContext` as the parent.
* `.MainQueueConcurrencyType` will set `mainContext` as the parent.

These child contexts should be saved using the `save(context:withCompletion:)` method. Saving the child context will propagate changes through the parent context and then to the persistent store.

### Saving

It is important to note that the `save(context:withCompletion:)` method is asynchronous. This means any code that is reliant on the save being complete should be handed to the method in the optional completion block. The `saveMainContext()` and `saveBackgroundContext() methods both use this method and can also take an optional completion block.

### CoreDataManagerSettable

Each view controller that needs access to the `CoreDataManager` should conform to `CoreDataManagerSettable`, which allows it to be passed around more easily in `prepare(for:sender:)`. For example:

```
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let controller = segue.destination as? CoreDataManagerSettable {
            controller.coreDataManager = coreDataManager
        }
        
        if let navController = segue.destination as? UINavigationController, let controller = navController.topViewController as? CoreDataManagerSettable {
            controller.coreDataManager = coreDataManager
        }
    }

```

## ManagedObjectType

Managed object type has convenience methods for:

* __Inserting Objects__
	*  `insertObject(withUniqueKeyValue uniqueKeyValue: Any, inContext context: NSManagedObjectContext, configure: ManagedObjectConfigurationBlock? = nil) -> Self`

		* The insert methods take an optional configure block which allow you set values on the object at the point of creation
		* Takes an identifier as a parameter, this identifier is set upon creation.
		* Returns the object after insertion, however result is discardable
	
* __Fetching Objects__
	* `fetchObject(withUniqueKeyValue uniqueKeyValue: Any, inContext context: NSManagedObjectContext) -> Self? `
	* `fetch(inContext context: NSManagedObjectContext, withConfigurationBlock configure: FetchRequestConfigurationBlock? = nil) -> [Self]`
		* Takes an optional ConfigurationBlockParameter which is a `FetchRequestConfigurationBlock`
		* Creates a fetchRequest using configuration block and returns all objects matching the fetch request
		* If no configuration block supplied returns all objects
	* `fetchOrInsertObject(withUniqueKeyValue uniqueKeyValue: Any, inContext context: NSManagedObjectContext, withConfigurationBlock configure: ManagedObjectConfigurationBlock? = nil) -> Self`
		* Takes an optional configure block which allow you set values on the object at the point of creation
		* Takes an identifier as a parameter
		* If an object exists with the identifier, that object is fetched and configured
		* If there is no object with the identifier, one is created and configured
		* Returns the object with identifier, however result is discardable 	 
* __Deleting Objects__
	* `delete(inContext context: NSManagedObjectContext, matchingPredicate predicate: NSPredicate? = nil)`
		* Deletes all objects matching predicate
		* If no predicate is supplied then it deletes all objects for that ModelObject

* __Counting Objects__ 
	* `count(inContext context: NSManagedObjectContext, matchingPredicate predicate: NSPredicate? = nil) -> Int`
		* Takes optional predicate
		* returns the count of all objects or all objects matching the predicate 
		
`ManagedObjectType` has a property called defaultSortDescriptors, this is of type `[NSSortDescriptor]` which allows you to provide a default sort order for you managed object.  You can then access a SortedFetchRequest which returns a fetchRequest configured with these sortDescriptors. 
It also has a method for returning a Fetch Request with no sortDescriptors configured.	
### CoreDataOperation

`CoreDataOperation` is a simple operation which should be used for operations that `insert` or `delete ` managed objects.

Simply sub class `CoreDataOperation` then override `performWork(inContext context: NSManagedObjectContext)`

* Note when the operation starts a child context is made, all work is done on this context.
* You must call `finish()` in your implementation of `performWork(inContext context: NSManagedObjectContext)`
* When `finish()` is called the context is safely saved
* `CoreDataOperation` inherits from `ConcurrentOperation` and there fore can return a `Result`  


### DataSource and Delegate

Using the tableView Data source and delegate classes in THRCoreData

First add the following type-alias to your TableViewController for readability ` fileprivate typealias DataProvider = FetchedResultsDataProvider<YourTableViewController>`

Next add these properties to your TableViewController

```
fileprivate var dataProvider: DataProvider!
fileprivate var dataSource: TableViewDataSource<YourTableViewController, DataProvider>!
```

Add this function and call it in `viewDidLoad`

```
fileprivate func setupTableView() {

        // You can configure a different fetch request here if needed
        
        let frc = NSFetchedResultsController(fetchRequest: YourManagedObject.sortedFetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        dataProvider = FetchedResultsDataProvider(fetchedResultsController: frc, delegate: self)
        dataSource = TableViewDataSource(tableView: tableView, dataProvider: dataProvider, delegate: self)
    }
```

Finally conform to the data source and provider protocols as shown below. 

```
extension YourTableViewController: DataProviderDelegate {
    
    func dataProviderDidUpdate(updates: [DataProviderUpdate<YourManagedObject>]?) {
        dataSource?.processUpdates(updates: updates)
    }
}
```
```
extension YourTableViewController: DataSourceDelegate {
    
    func cellIdentifier(forObject object: YourManagedObject) -> String {
        return "yourCellIdentifier"
    }
    
    func configure(cell: YourTableViewCell, forObject object: YourManagedObject) {
        
        // Configure your cell here instead of cellForRowAtIndexPath
    }
}
```
 * Note instead of returning `"yourCellIdentifier"` you can use the `CellIdentifierType` found in [THRUtilities]()
