//
//  FetchedTableViewDataSource.swift
//  THRCoreData
//
//  Created by David Yates on 07/03/2018.
//  Copyright © 2018 3Squared Ltd. All rights reserved.
//

import UIKit
import CoreData

public protocol FetchedTableViewDataSourceDelegate: class {
    associatedtype Object: NSManagedObject
    associatedtype Cell: UITableViewCell
    func configure(_ cell: Cell, with object: Object)
    
    // Optional
    var emptyView: UIView? { get }
    var shouldShowSectionIndexTitles: Bool { get }
    
    func titleForHeader(in section: Int) -> String?
    func titleForFooter(in section: Int) -> String?
    func canEditRow(at indexPath: IndexPath) -> Bool
    func commit(editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath)
    func canMoveRow(at indexPath: IndexPath) -> Bool
    func move(rowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath)
}

public extension FetchedTableViewDataSourceDelegate {
    
    var emptyView: UIView? { return nil }
    
    var shouldShowSectionIndexTitles: Bool { return false }
    
    func canEditRow(at indexPath: IndexPath) -> Bool { return false }
    
    func commit(editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) { }
    
    func canMoveRow(at indexPath: IndexPath) -> Bool { return false }
    
    func move(rowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) { }
    
    func titleForHeader(in section: Int) -> String? { return nil }
    
    func titleForFooter(in section: Int) -> String? { return nil }
}

public class FetchedTableViewDataSource<Delegate: FetchedTableViewDataSourceDelegate>: NSObject, UITableViewDataSource, NSFetchedResultsControllerDelegate {
    
    public typealias Object = Delegate.Object
    public typealias Cell = Delegate.Cell
    
    private let tableView: UITableView
    private let fetchedResultsController: NSFetchedResultsController<Object>
    private let cellIdentifier: String
    private weak var delegate: Delegate!
    private var updates: [Update<Object>] = []

    public var animateUpdates: Bool = true
    public var onDidChangeContent: (() -> Void)?
    
    public var cacheName: String? {
        return fetchedResultsController.cacheName
    }
    
    public var isEmpty: Bool {
        return numberOfSections == 0 || (numberOfItems(in: 0) == 0)
    }
    
    public var numberOfSections: Int {
        guard let sections = fetchedResultsController.sections else { return 0 }
        return sections.count
    }
    
    public var sectionIndexTitles: [String] {
        return fetchedResultsController.sectionIndexTitles
    }
    
    public var sectionNameKeyPath: String? {
        return fetchedResultsController.sectionNameKeyPath
    }
    
    public required init(tableView: UITableView, cellIdentifier: String, fetchedResultsController: NSFetchedResultsController<Object>, delegate: Delegate) {
        self.tableView = tableView
        self.cellIdentifier = cellIdentifier
        self.fetchedResultsController = fetchedResultsController
        self.delegate = delegate
        super.init()
        fetchedResultsController.delegate = self
        try! fetchedResultsController.performFetch()
        tableView.dataSource = self
        tableView.reloadData()
        showEmptyViewIfNeeded()
    }
    
    public func indexPath(forObject object: Object) -> IndexPath? {
        return fetchedResultsController.indexPath(forObject: object)
    }
    
    public func name(in section: Int) -> String? {
        guard let sectionInfo = fetchedResultsController.sections?[section] else { return nil }
        return sectionInfo.name
    }
    
    public func numberOfItems(in section: Int) -> Int {
        guard let sectionInfo = fetchedResultsController.sections?[section] else { return 0 }
        return sectionInfo.numberOfObjects
    }
    
    public func object(at indexPath: IndexPath) -> Object {
        return fetchedResultsController.object(at: indexPath)
    }
    
    public func section(forSectionIndexTitle title: String, at index: Int) -> Int {
        return fetchedResultsController.section(forSectionIndexTitle: title, at: index)
    }
    
    public func sectionInfo(forSection section: Int) -> NSFetchedResultsSectionInfo {
        return fetchedResultsController.sections![section] as NSFetchedResultsSectionInfo
    }
    
    public func reconfigureFetchRequest(_ configure: (NSFetchRequest<Object>) -> ()) {
        NSFetchedResultsController<NSFetchRequestResult>.deleteCache(withName: cacheName)
        configure(fetchedResultsController.fetchRequest)
        do { try fetchedResultsController.performFetch() } catch { fatalError("fetch request failed") }
        tableView.reloadData()
    }
    
    public func showEmptyViewIfNeeded() {
        if isEmpty, let emptyView = delegate.emptyView {
            tableView.backgroundView = emptyView
        } else {
            let view = UIView()
            view.backgroundColor = tableView.backgroundColor
            tableView.backgroundView = view
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
        return delegate.shouldShowSectionIndexTitles ? sectionIndexTitles : nil
    }
    
    public func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return section(forSectionIndexTitle: title, at: index)
    }
    
    // MARK: NSFetchedResultsControllerDelegate
    
    public func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard animateUpdates && tableView.window != nil else { return }
        
        updates = []
    }
    
    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        guard animateUpdates && tableView.window != nil else { return }
        
        if let indexPath = indexPath, let newIndexPath = newIndexPath {
            updates.append(.move(indexPath, newIndexPath))
            return
        }

        switch type {
        case .insert:
            guard let newIndexPath = newIndexPath else { fatalError("Index path should be not nil") }
            updates.append(.insert(newIndexPath))
        case .update:
            guard let indexPath = indexPath else { fatalError("Index path should be not nil") }
            updates.append(.update(indexPath, object(at: indexPath)))
        case .move:
            guard let indexPath = indexPath else { fatalError("Index path should be not nil") }
            guard let newIndexPath = newIndexPath else { fatalError("New index path should be not nil") }
            updates.append(.update(indexPath, object(at: indexPath)))
            updates.append(.move(indexPath, newIndexPath))
        case .delete:
            guard let indexPath = indexPath else { fatalError("Index path should be not nil") }
            updates.append(.delete(indexPath))
        }
    }
    
    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        guard animateUpdates && tableView.window != nil else { return }
        
        switch type {
        case .insert:
            updates.append(.insertSection(at: sectionIndex))
        case .delete:
            updates.append(.deleteSection(at: sectionIndex))
        default:
            break
        }
    }
    
    public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard animateUpdates, tableView.window != nil else {
            tableView.reloadData()
            showEmptyViewIfNeeded()
            onDidChangeContent?()
            return
        }
        
        let batchUpdates: () -> Void = {
            self.updates.forEach { (update) in
                switch update {
                case .insert(let indexPath):
                    self.tableView.insertRows(at: [indexPath], with: .fade)
                case .update(let indexPath, let object):
                    guard let cell = self.tableView.cellForRow(at: indexPath) as? Cell else { fatalError("Wrong cell type") }
                    self.delegate.configure(cell, with: object)
                case .move(let indexPath, let newIndexPath):
                    self.tableView.moveRow(at: indexPath, to: newIndexPath)
                case .delete(let indexPath):
                    self.tableView.deleteRows(at: [indexPath], with: .fade)
                case .deleteSection(let section):
                    self.tableView.deleteSections(IndexSet(integer: section), with: .fade)
                case .insertSection(let section):
                    self.tableView.insertSections(IndexSet(integer: section), with: .fade)
                }
            }
        }
        
        if #available(iOS 11.0, *) {
            tableView.performBatchUpdates(batchUpdates) { [weak self] (success) in
                guard let strongSelf = self else { return }
                strongSelf.showEmptyViewIfNeeded()
                strongSelf.onDidChangeContent?()
            }
        } else {
            tableView.beginUpdates()
            batchUpdates()
            tableView.endUpdates()
            showEmptyViewIfNeeded()
            onDidChangeContent?()
        }
    }
}
