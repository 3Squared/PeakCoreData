//
//  EmptyTableViewController.swift
//  THRCoreDataExample
//
//  Created by David Yates on 21/12/2016.
//  Copyright © 2016 3Squared Ltd. All rights reserved.
//

import UIKit
import CoreData
import THRCoreData

class EventsTableViewController: UITableViewController, PersistentContainerSettable {

    var persistentContainer: NSPersistentContainer!

    fileprivate typealias DataProvider = FetchedResultsDataProvider<EventsTableViewController>
    fileprivate var dataProvider: DataProvider!
    fileprivate var dataSource: TableViewDataSource<EventsTableViewController, DataProvider>!
    
    fileprivate lazy var dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .long
        df.timeStyle = .short
        return df
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        setupTableView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func addButtonTapped(_ sender: Any) {
        let newEvent = Event.insertObject(inContext: viewContext)
        newEvent.date = Date()
        do {
            try viewContext.save()
        } catch {
            fatalError()
        }
    }

    fileprivate func setupTableView() {
        let frc = NSFetchedResultsController(fetchRequest: Event.sortedFetchRequest(), managedObjectContext: viewContext, sectionNameKeyPath: nil, cacheName: nil)
        dataProvider = FetchedResultsDataProvider(fetchedResultsController: frc, delegate: self)
        dataSource = TableViewDataSource(tableView: tableView, dataProvider: dataProvider, delegate: self)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension EventsTableViewController: DataProviderDelegate {
    
    func dataProviderDidUpdate(updates: [DataProviderUpdate<Event>]?) {
        viewContext.performAndWait {
            self.dataSource?.processUpdates(updates: updates)
        }
    }
}

extension EventsTableViewController: DataSourceDelegate {

    func emptyView() -> UIView? {
        let nibViews = Bundle.main.loadNibNamed(EmptyView.nibName, owner: self, options: nil)
        let view = nibViews?.first as! EmptyView
        view.titleLabel.text = "No events in table view"
        view.subtitleLabel.text = "Not a sausage."
        return view
    }
    
    func cellIdentifier(forObject object: Event) -> String {
        return EventTableViewCell.cellIdentifier
    }
    
    func configure(cell: EventTableViewCell, forObject object: Event) {
        cell.textLabel?.text = dateFormatter.string(from: (object.date! as Date))
    }
    
    func canEditRow(at indexPath: IndexPath) -> Bool {
        return true
    }
    
    func commit(editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let objectToDelete = dataProvider.object(at: indexPath)
            viewContext.delete(objectToDelete)
            do {
                try viewContext.save()
            } catch {
                fatalError()
            }
        }
    }
}
