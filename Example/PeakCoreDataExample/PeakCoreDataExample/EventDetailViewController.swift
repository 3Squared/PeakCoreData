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
    }

    @IBAction func refreshButtonTapped(_ sender: Any) {
        event.date = Date()
        saveViewContext()
    }
    
    @IBAction func trashButtonTapped(_ sender: Any) {
        viewContext.delete(event)
        saveViewContext()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return event.attendees?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: AttendeeTableViewCell.cellIdentifier, for: indexPath) as! AttendeeTableViewCell
        let attendee = event.attendees?.allObjects[indexPath.row] as! Person
        cell.textLabel?.text = attendee.name
        return cell
    }
    
    private func updateLabels() {
        dateLabel.text = event.date != nil ? dateFormatter.string(from: event.date!) : "No Date"
        attendeeCountLabel.text = "\(event.attendees?.count ?? 0)"
    }
}
