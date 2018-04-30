//
//  FetchedTableViewDataSource.swift
//  THRCoreData
//
//  Created by David Yates on 07/03/2018.
//  Copyright © 2018 3Squared Ltd. All rights reserved.
//

import UIKit
import CoreData

public protocol FetchedTableViewDataSourceDelegate: TableViewUpdatable, HasEmptyView {
    var rowAnimation: UITableViewRowAnimation { get }
    func titleForHeader(in section: Int) -> String?
    func titleForFooter(in section: Int) -> String?
    func canEditRow(at indexPath: IndexPath) -> Bool
    func commit(editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath)
    func canMoveRow(at indexPath: IndexPath) -> Bool
    func move(rowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath)
}

public extension FetchedTableViewDataSourceDelegate {
    var rowAnimation: UITableViewRowAnimation { return .automatic }
    func canEditRow(at indexPath: IndexPath) -> Bool { return false }
    func commit(editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) { }
    func canMoveRow(at indexPath: IndexPath) -> Bool { return false }
    func move(rowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) { }
    func titleForHeader(in section: Int) -> String? { return nil }
    func titleForFooter(in section: Int) -> String? { return nil }
}

public class FetchedTableViewDataSource<Delegate: FetchedTableViewDataSourceDelegate>: NSObject, UITableViewDataSource {
    public typealias Object = Delegate.Object
    public typealias Cell = Delegate.Cell
    
    private let tableView: UITableView
    private let cellIdentifier: String
    private let dataProvider: FetchedDataProvider<FetchedTableViewDataSource>
    private weak var delegate: Delegate!
    
    public var animateUpdates: Bool = true
    public var showSectionIndexTitles: Bool = false
    public var onDidChangeContent: (() -> Void)?
    
    public var cacheName: String? {
        return dataProvider.cacheName
    }
    
    public var fetchedObjectsCount: Int {
        return dataProvider.fetchedObjectsCount
    }
    
    public var isEmpty: Bool {
        return dataProvider.isEmpty
    }
    
    public var numberOfSections: Int {
        return dataProvider.numberOfSections
    }
    
    public var sectionIndexTitles: [String] {
        return dataProvider.sectionIndexTitles
    }
    
    public var sectionNameKeyPath: String? {
        return dataProvider.sectionNameKeyPath
    }
    
    public required init(tableView: UITableView, cellIdentifier: String, fetchedResultsController: NSFetchedResultsController<Object>, delegate: Delegate) {
        self.tableView = tableView
        self.cellIdentifier = cellIdentifier
        self.delegate = delegate
        self.dataProvider = FetchedDataProvider(fetchedResultsController: fetchedResultsController)
        super.init()
        tableView.dataSource = self
        dataProvider.delegate = self
    }
    
    public func indexPath(forObject object: Object) -> IndexPath? {
        return dataProvider.indexPath(forObject: object)
    }
    
    public func name(in section: Int) -> String? {
        return dataProvider.name(in: section)
    }
    
    public func numberOfItems(in section: Int) -> Int {
        return dataProvider.numberOfItems(in: section)
    }
    
    public func object(at indexPath: IndexPath) -> Object {
        return dataProvider.object(at: indexPath)
    }
    
    public func performFetch() {
        dataProvider.performFetch()
    }
    
    public func section(forSectionIndexTitle title: String, at index: Int) -> Int {
        return dataProvider.section(forSectionIndexTitle: title, at: index)
    }
    
    public func sectionInfo(forSection section: Int) -> NSFetchedResultsSectionInfo {
        return dataProvider.sectionInfo(forSection: section)
    }
    
    public func reconfigureFetchRequest(_ configure: (NSFetchRequest<Object>) -> ()) {
        dataProvider.reconfigureFetchRequest(configure)
    }
    
    public func showEmptyViewIfNeeded() {
        if isEmpty, let emptyView = delegate.emptyView {
            tableView.backgroundView = emptyView
        } else {
            tableView.backgroundView = nil
        }
    }
    
    // MARK: UITableViewDataSource
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return numberOfSections
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfItems(in: section)
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? Cell else {
            fatalError("Unexpected cell type at \(indexPath)")
        }
        delegate.configure(cell, with: object(at: indexPath))
        return cell
    }
    
    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return delegate.titleForHeader(in: section)
    }
    
    public func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return delegate.titleForFooter(in: section)
    }
    
    public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return delegate.canEditRow(at: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        delegate.commit(editingStyle: editingStyle, forRowAt: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return delegate.canMoveRow(at: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        delegate.move(rowAt: sourceIndexPath, to: destinationIndexPath)
    }
    
    public func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return showSectionIndexTitles ? sectionIndexTitles : nil
    }
    
    public func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return section(forSectionIndexTitle: title, at: index)
    }
    
    public func cleanUp() {
        dataProvider.cleanUp()
    }
}

extension FetchedTableViewDataSource: FetchedDataProviderDelegate {
    
    func dataProviderDidUpdate(updates: [FetchedUpdate<Delegate.Object>]?) {
        guard let updates = updates, animateUpdates, tableView.window != nil else {
            tableView.reloadData()
            showEmptyViewIfNeeded()
            onDidChangeContent?()
            return
        }
        
        delegate.process(updates: updates, for: tableView, with: delegate.rowAnimation) { [weak self] _ in
            guard let strongSelf = self else { return }
            strongSelf.showEmptyViewIfNeeded()
            strongSelf.onDidChangeContent?()
        }
    }
}
