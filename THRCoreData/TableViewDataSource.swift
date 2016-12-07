//
//  TableViewDataSource.swift
//  THRCoreData
//
//  Created by David Yates on 07/12/2016.
//  Copyright © 2016 3Squared Ltd. All rights reserved.
//

import UIKit

public class TableViewDataSource<Delegate: DataSourceDelegate, Data: DataProvider>: NSObject, UITableViewDataSource where Delegate.Object == Data.Object {
    
    private let tableView: UITableView
    private let dataProvider: Data
    private weak var delegate: Delegate!
    
    required public init(tableView: UITableView, dataProvider: Data, delegate: Delegate) {
        self.tableView = tableView
        self.dataProvider = dataProvider
        self.delegate = delegate
        super.init()
        tableView.dataSource = self
        tableView.reloadData()
    }
    
    public var selectedObject: Data.Object? {
        guard let indexPath = tableView.indexPathForSelectedRow else { return nil }
        return dataProvider.object(at: indexPath)
    }
    
    public func processUpdates(updates: [DataProviderUpdate<Data.Object>]?) {
        guard let updates = updates, self.tableView.window != nil else {
            return self.tableView.reloadData()
        }
        
        self.tableView.beginUpdates()
        for update in updates {
            switch update {
            case .insert(let indexPath):
                self.tableView.insertRows(at: [indexPath as IndexPath], with: .fade)
            case .update(let indexPath, let object):
                guard let cell = self.tableView.cellForRow(at: indexPath as IndexPath) as? Delegate.Cell else { break }
                self.delegate.configure(cell: cell, forObject: object)
            case .move(let fromIndexPath, let toIndexPath):
                self.tableView.deleteRows(at: [fromIndexPath as IndexPath], with: .fade)
                self.tableView.insertRows(at: [toIndexPath as IndexPath], with: .fade)
            case .delete(let indexPath):
                self.tableView.deleteRows(at: [indexPath as IndexPath], with: .fade)
            case .insertSection(let section):
                let indexSet = IndexSet(integer: section)
                self.tableView.insertSections(indexSet, with: .fade)
            case .deleteSection(let section):
                let indexSet = IndexSet(integer: section)
                self.tableView.deleteSections(indexSet, with: .fade)
            }
        }
        self.tableView.endUpdates()
    }
    
    public func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return delegate.shouldShowSectionIndexTitles() ? dataProvider.sectionIndexTitles : nil
    }
    
    // MARK: UITableViewDataSource
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return dataProvider.numberOfSections
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataProvider.numberOfItems(in: section)
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let object = dataProvider.object(at: indexPath)
        let identifier =  delegate.cellIdentifier(forObject: object)
        guard let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? Delegate.Cell else { fatalError("Unexpected cell type at \(indexPath)") }
        delegate.configure(cell: cell, forObject: object)
        return cell as! UITableViewCell
    }
    
    public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return delegate.canEditRow(at: indexPath)
    }
}
