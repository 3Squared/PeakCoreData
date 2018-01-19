//
//  EventsCollectionViewController.swift
//  THRCoreDataExample
//
//  Created by David Yates on 21/12/2016.
//  Copyright © 2016 3Squared Ltd. All rights reserved.
//

import UIKit
import THRCoreData
import CoreData

class EventsCollectionViewController: UICollectionViewController, PersistentContainerSettable {
    
    var persistentContainer: PersistentContainer!
    
    fileprivate typealias DataProvider = FetchedResultsDataProvider<EventsCollectionViewController>
    fileprivate var dataProvider: DataProvider!
    fileprivate var dataSource: CollectionViewDataSource<EventsCollectionViewController, DataProvider>!
    
    fileprivate lazy var dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .short
        df.timeStyle = .short
        return df
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func addButtonTapped(_ sender: Any) {
        let newEvent = Event.insertObject(inContext: mainContext)
        newEvent.date = Date()
        do {
            try mainContext.save()
        } catch {
            fatalError()
        }
    }
    
    fileprivate func setupTableView() {
        let frc = NSFetchedResultsController(fetchRequest: Event.sortedFetchRequest(), managedObjectContext: mainContext, sectionNameKeyPath: nil, cacheName: nil)
        dataProvider = FetchedResultsDataProvider(fetchedResultsController: frc, delegate: self)
        dataSource = CollectionViewDataSource(collectionView: self.collectionView!, dataProvider: dataProvider, delegate: self)
    }
}

extension EventsCollectionViewController: DataProviderDelegate {
    
    func dataProviderDidUpdate(updates: [DataProviderUpdate<Event>]?) {
        mainContext.performAndWait {
            self.dataSource?.processUpdates(updates: updates)
        }
    }
}

extension EventsCollectionViewController: DataSourceDelegate {
    
    func emptyView() -> UIView? {
        let nibViews = Bundle.main.loadNibNamed(EmptyView.nibName, owner: self, options: nil)
        let view = nibViews?.first as! EmptyView
        view.titleLabel.text = "No events in collection view"
        view.subtitleLabel.text = "Nope. Nothing in here."
        return view
    }
    
    func cellIdentifier(forObject object: Event) -> String {
        return EventCollectionViewCell.cellIdentifier
    }
    
    func configure(cell: EventCollectionViewCell, forObject object: Event) {
        cell.dateLabel.text = dateFormatter.string(from: (object.date! as Date))
    }
}
