//
//  EventDetailViewController.swift
//  PeakCoreDataExample
//
//  Created by David Yates on 16/03/2018.
//  Copyright © 2018 3Squared Ltd. All rights reserved.
//

import UIKit
import CoreData
import PeakCoreData

class EventDetailViewController: UITableViewController, PersistentContainerSettable {

    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var attendeeCountLabel: UILabel!
    
    var persistentContainer: NSPersistentContainer!
    var event: Event!
    var eventObserver: ManagedObjectObserver<Event>!

    private var dataSource: FetchedTableViewDataSource<EventDetailViewController>!
    
    private lazy var dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .long
        df.timeStyle = .short
        return df
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        eventObserver = ManagedObjectObserver(managedObject: event)
        eventObserver.startObserving() { [weak self] obj, changeType in
            guard let strongSelf = self else { return }
            switch changeType {
            case .initialised, .refreshed, .updated:
                strongSelf.updateLabels()
            case .deleted:
                strongSelf.navigationController?.popToRootViewController(animated: true)
            }
        }
        setupTableView()
    }

    @IBAction func refreshButtonTapped(_ sender: Any) {
        event.date = Date()
        saveViewContext()
    }
    
    @IBAction func trashButtonTapped(_ sender: Any) {
        viewContext.delete(event)
        saveViewContext()
    }
    
    private func setupTableView() {
        let fetchRequest = Person.sortedFetchRequest {
            $0.predicate = Person.predicate(forEventID: self.event.uniqueID!)
        }
        
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: viewContext, sectionNameKeyPath: nil, cacheName: nil)
        dataSource = FetchedTableViewDataSource(tableView: tableView, fetchedResultsController: frc, delegate: self)
        dataSource.animateUpdates = true
        dataSource.onDidChangeContent = {
            print("Event Detail Table View - Something changed")
        }
        dataSource.performFetch()
    }
    
    private func updateLabels() {
        dateLabel.text = event.date != nil ? dateFormatter.string(from: event.date!) : "No Date"
        attendeeCountLabel.text = "\(event.attendees?.count ?? 0)"
    }
}

extension EventDetailViewController: FetchedTableViewDataSourceDelegate {
    func identifier(forCellAt indexPath: IndexPath) -> String {
        return AttendeeTableViewCell.cellIdentifier
    }
    
    func configure(_ cell: AttendeeTableViewCell, with object: Person) {
        cell.textLabel?.text = object.name
    }
}
