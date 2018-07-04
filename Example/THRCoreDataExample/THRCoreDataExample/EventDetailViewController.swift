//
//  EventDetailViewController.swift
//  THRCoreDataExample
//
//  Created by David Yates on 16/03/2018.
//  Copyright © 2018 3Squared Ltd. All rights reserved.
//

import UIKit
import CoreData
import THRCoreData

class EventDetailViewController: UIViewController, PersistentContainerSettable {

    @IBOutlet weak var dateLabel: UILabel!
    
    var persistentContainer: NSPersistentContainer!
    var event: Event!
    var eventObserver: ManagedObjectObserver<Event>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        eventObserver = ManagedObjectObserver(managedObject: event)
        eventObserver.startObserving() { [weak self] obj, changeType in
            guard let strongSelf = self else { return }
            switch changeType {
            case .initialised, .refreshed, .updated:
                strongSelf.updateDateLabel()
            case .deleted:
                strongSelf.navigationController?.popToRootViewController(animated: true)
            }
        }
    }
    
    func updateDateLabel() {
        dateLabel.text = event.date?.description ?? "No Date"
    }

    @IBAction func refreshButtonTapped(_ sender: Any) {
        event.date = Date()
        saveViewContext()
    }
    
    @IBAction func trashButtonTapped(_ sender: Any) {
        viewContext.delete(event)
        saveViewContext()
    }
}
