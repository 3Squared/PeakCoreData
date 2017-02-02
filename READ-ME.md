# THRCoreData


### CoreDataManager

Creating a `CoreDataManager` will set up your model, `PersistentStore` and `PersistentStoreCoordinator`. The `CoreDataManager` gives access to the main context, and a single background context.  

There is a convenience method for saving these ManagedObjectContext's

`saveMainContext` and `saveBackgroundContext`  

These methods check to see if the context has changes before saving, then safely saves the context and handles any errors. They also take an optional completion block parameter which default value is nil.

You should create your `CoreDataManager` in your app delegate,  Passing it the name of your dataModel as a parameter.  This should then be passed into each viewController using the `CoreDataManagerSettable` protocol.

Finally you should save the mainContext in `applicationWillTerminate`

```
func applicationWillTerminate(_ application: UIApplication) {
	coreDataManager.saveMainContext()
}
```  

### CoreDataManagerSettable

Each viewController that needs to access the `CoreDataManager` should conform to `CoreDataManagerSettable`

After Creating your CoreDataManager you need to pass it to your initial view controller using `window?.rootViewController` if your rootViewController is a `UINavigationController` then you will need to cast to  UINavigationController then access its topViewController.  Finally cast the initial controller to type `CoreDataManagerSettable` and set the coreDataManager.

Example code:

`UINavigationController is initial view controller`

```
coreDataManager = CoreDataManager(modelName: "Model_Name")
guard let navigationController = window?.rootViewController as? UINavigationController else { fatalError("Wrong view controller type") }
     
if let rootViewController = navigationController.topViewController as? CoreDataManagerSettable {
	rootViewController.coreDataManager = coreDataManager
}
```

`UITabBarController is initial view controller`

```
coreDataManager = CoreDataManager(modelName: "Model_Name")
guard let tabBarController = window?.rootViewController as? UITabBarController else { fatalError("Wrong view controller type") }
        
for vc in tabBarController.viewControllers! {
	if let navigationController = vc as? UINavigationController, let rootViewController = navigationController.topViewController as? CoreDataManagerSettable {
		rootViewController.coreDataManager = coreDataManager
    }
}

```

### ManagedObjectType

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
