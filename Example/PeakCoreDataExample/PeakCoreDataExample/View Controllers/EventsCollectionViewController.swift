//
//  EventsCollectionViewController.swift
//  PeakCoreDataExample
//
//  Created by David Yates on 21/12/2016.
//  Copyright © 2016 3Squared Ltd. All rights reserved.
//

import UIKit
import CoreData
import PeakCoreData

class EventsCollectionViewController: UICollectionViewController, PersistentContainerSettable {
    
    var persistentContainer: NSPersistentContainer!
    
    lazy var operationQueue = OperationQueue()
    
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
        persistentContainer.performBackgroundTask { backgroundContext in
            print("\nEntity Counts Before Batch Delete\n-----")
            self.printEntityCounts()
            backgroundContext.batchDeleteAllEntities(mergingInto: [backgroundContext, self.viewContext])
            print("\nEntity Counts After Batch Delete\n-----")
            self.printEntityCounts()
            print("")
        }
    }
    
    @IBAction func addButtonTapped(_ sender: Any) {
        let operation = CoreDataBatchImportOperation<EventJSON>(persistentContainer: persistentContainer)
        operation.input = Result { EventJSON.generate(25) }
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
    
    private func printEntityCounts() {
        if let entities = viewContext.persistentStoreCoordinator?.managedObjectModel.entities {
            for entity in entities {
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity.name!)
                do {
                    let fetchedObjects = try viewContext.fetch(fetchRequest)
                    print("\(entity.name!): \(fetchedObjects.count)")
                } catch {
                    fatalError("Failed to fetch objects: \(error)")
                }
            }
        }
    }
}

extension EventsCollectionViewController: FetchedCollectionViewDataSourceDelegate {
    
    func reuseIdentifier(forCellAt indexPath: IndexPath) -> String {
        return EventCollectionViewCell.cellIdentifier
    }
    
    func configure(_ cell: EventCollectionViewCell, with object: Event) {
        cell.dateLabel.text = dateFormatter.string(from: (object.date! as Date))
    }
}
