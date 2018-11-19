//
//  EventsCollectionViewController.swift
//  PeakCoreDataExample
//
//  Created by David Yates on 21/12/2016.
//  Copyright © 2016 3Squared Ltd. All rights reserved.
//

import UIKit
import CoreData
import PeakResult
import PeakCoreData

class EventsCollectionViewController: UICollectionViewController, PersistentContainerSettable {
    
    var persistentContainer: NSPersistentContainer!
    
    var operationQueue: OperationQueue {
        let queue = OperationQueue()
        return queue
    }
    
    private var dataSource: FetchedCollectionViewDataSource<EventsCollectionViewController>!
    
    private lazy var dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .short
        df.timeStyle = .short
        return df
    }()
    
    lazy var emptyView: UIView? = {
        let nibViews = Bundle.main.loadNibNamed(EmptyView.nibName, owner: self, options: nil)
        let view = nibViews?.first as! EmptyView
        view.titleLabel.text = "No events in collection view"
        view.subtitleLabel.text = "Nothing. Nada."
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }
    
    @IBAction func deleteButtonTapped(_ sender: Any) {
        Event.batchDelete(in: viewContext)
    }
    
    @IBAction func addButtonTapped(_ sender: Any) {
        let numberOfItems = 100
        var intermediateItems: [EventJSON] = []
        for item in 0..<numberOfItems {
            let id = UUID().uuidString
            let date = Date().addingTimeInterval(-Double(item))
            let intermediate = EventJSON(uniqueID: id, date: date)
            intermediateItems.append(intermediate)
        }
        let operation = CoreDataBatchImportOperation<EventJSON>(with: persistentContainer)
        operation.input = Result { intermediateItems }
        operationQueue.addOperation(operation)
    }
    
    private func setupTableView() {
        let frc = NSFetchedResultsController(fetchRequest: Event.sortedFetchRequest(), managedObjectContext: viewContext, sectionNameKeyPath: nil, cacheName: nil)
        dataSource = FetchedCollectionViewDataSource(collectionView: collectionView, fetchedResultsController: frc, delegate: self)
        dataSource.animateUpdates = true
        dataSource.onDidChangeContent = {
            print("Collection View - Something changed")
        }
        dataSource.performFetch()
    }
}

extension EventsCollectionViewController: FetchedCollectionViewDataSourceDelegate {
    
    var cellReuseIdentifier: String {
        return EventCollectionViewCell.cellIdentifier
    }
    
    func configureCell(_ cell: EventCollectionViewCell, with object: Event) {
        cell.dateLabel.text = dateFormatter.string(from: (object.date! as Date))
    }
}
