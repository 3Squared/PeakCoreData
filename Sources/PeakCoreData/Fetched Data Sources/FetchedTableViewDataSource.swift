//
//  FetchedTableViewDataSource.swift
//  PeakCoreData
//
//  Created by David Yates on 07/03/2018.
//  Copyright © 2018 3Squared Ltd. All rights reserved.
//

#if canImport(UIKit)

import UIKit
import CoreData

public protocol FetchedTableViewDataSourceDelegate: TableViewDecoratable, TableViewUpdatable, HasEmptyView {
    // Required
    func identifier(forCellAt indexPath: IndexPath) -> String
    // Optional
    var rowAnimation: UITableView.RowAnimation { get }
    func titleForHeader(in section: Int) -> String?
    func titleForFooter(in section: Int) -> String?
    func canEditRow(at indexPath: IndexPath) -> Bool
    func commit(editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath)
    func canMoveRow(at indexPath: IndexPath) -> Bool
    func moveRow(at sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath)
    func editingStyle(forRowAt: IndexPath) -> UITableViewCell.EditingStyle
    func leadingSwipeActions(forRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
    func trailingSwipeActions(forRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
}

public extension FetchedTableViewDataSourceDelegate {
    var rowAnimation: UITableView.RowAnimation { .automatic }
    func titleForHeader(in section: Int) -> String? { nil }
    func titleForFooter(in section: Int) -> String? { nil }
    func canEditRow(at indexPath: IndexPath) -> Bool { false }
    func commit(editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) { }
    func canMoveRow(at indexPath: IndexPath) -> Bool { false }
    func moveRow(at sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) { }
    func editingStyle(forRowAt: IndexPath) -> UITableViewCell.EditingStyle { .none }
    func leadingSwipeActions(forRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? { nil }
    func trailingSwipeActions(forRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? { nil }
}

public class FetchedTableViewDataSource<Delegate: FetchedTableViewDataSourceDelegate>: NSObject, UITableViewDataSource, UITableViewDelegate {
    public typealias Object = Delegate.Object
    public typealias Cell = Delegate.Cell
    public typealias Header = Delegate.Header
    public typealias Footer = Delegate.Footer
    
    private let tableView: UITableView
    private let dataProvider: FetchedDataProvider<FetchedTableViewDataSource>
    private weak var delegate: Delegate!
    
    public var animateUpdates: Bool = true
    public var showSectionIndexTitles: Bool = false
    public var onDidChangeContent: (() -> Void)?
    
    public var cacheName: String? {
        dataProvider.cacheName
    }
    
    public var fetchedObjectsCount: Int {
        dataProvider.fetchedObjectsCount
    }
    
    public var isEmpty: Bool {
        dataProvider.isEmpty
    }
    
    public var numberOfSections: Int {
        dataProvider.numberOfSections
    }
    
    public var sectionIndexTitles: [String] {
        dataProvider.sectionIndexTitles
    }
    
    public var sectionNameKeyPath: String? {
        dataProvider.sectionNameKeyPath
    }
    
    public required init(tableView: UITableView, fetchedResultsController: NSFetchedResultsController<Object>, delegate: Delegate) {
        self.tableView = tableView
        self.delegate = delegate
        self.dataProvider = FetchedDataProvider(fetchedResultsController: fetchedResultsController)
        super.init()
        tableView.dataSource = self
        tableView.delegate = self
        dataProvider.delegate = self
    }
    
    public func indexPath(forObject object: Object) -> IndexPath? {
        dataProvider.indexPath(forObject: object)
    }
    
    public func name(in section: Int) -> String? {
        dataProvider.name(in: section)
    }
    
    public func numberOfItems(in section: Int) -> Int {
        dataProvider.numberOfItems(in: section)
    }
    
    public func object(at indexPath: IndexPath) -> Object {
        dataProvider.object(at: indexPath)
    }
    
    public func performFetch() {
        dataProvider.performFetch()
    }
    
    public func section(forSectionIndexTitle title: String, at index: Int) -> Int {
        dataProvider.section(forSectionIndexTitle: title, at: index)
    }
    
    public func sectionInfo(forSection section: Int) -> NSFetchedResultsSectionInfo {
        dataProvider.sectionInfo(forSection: section)
    }
    
    public func reconfigureFetchRequest(_ configure: (NSFetchRequest<Object>) -> Void) {
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
        numberOfSections
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        numberOfItems(in: section)
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = delegate.identifier(forCellAt: indexPath)
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? Cell else {
            fatalError("Unexpected cell type at \(indexPath)")
        }
        
        delegate.configure(cell, with: object(at: indexPath))
        
        return cell
    }
    
    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        delegate.titleForHeader(in: section)
    }
    
    public func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        delegate.titleForFooter(in: section)
    }
    
    public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        delegate.canEditRow(at: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        delegate.commit(editingStyle: editingStyle, forRowAt: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        delegate.canMoveRow(at: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        delegate.moveRow(at: sourceIndexPath, to: destinationIndexPath)
    }
    
    public func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        showSectionIndexTitles ? sectionIndexTitles : nil
    }
    
    public func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        section(forSectionIndexTitle: title, at: index)
    }
    
    // MARK: UITableViewDelegate
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.selectRow(at: indexPath, animated: animateUpdates, scrollPosition: .none)
        
        delegate.didSelect(object: object(at: indexPath), at: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: animateUpdates)
        
        delegate.didDeselect(object: object(at: indexPath), at: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        guard let identifier = delegate.identifier(forHeaderIn: section) else { return nil }
        guard let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: identifier) as? Header else { fatalError("Unexpected header type at \(section)") }
        
        delegate.configureHeader(view, for: section)
        
        return view
    }
    
    public func tableView(_ tableView: UITableView,
                          viewForFooterInSection section: Int) -> UIView? {
        
        guard let identifier = delegate.identifier(forFooterIn: section) else { return nil }
        guard let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: identifier) as? Footer else { fatalError("Unexpected footer type at \(section)") }
        
        delegate.configureFooter(view, for: section)
        
        return view
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        delegate.heightForHeader(in: section)
    }
    
    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        delegate.heightForFooter(in: section)
    }
    
    public func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        guard let view = view as? Header else { fatalError("Unexpected header type at \(section)") }
        
        delegate.willDisplay(headerView: view, for: section)
    }
    
    public func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        
        guard let view = view as? Footer else { fatalError("Unexpected footer type at \(section)") }
        
        delegate.willDisplay(footerView: view, for: section)
    }
    
    public func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        delegate.leadingSwipeActions(forRowAt: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        delegate.trailingSwipeActions(forRowAt: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        delegate.editingStyle(forRowAt: indexPath)
    }
}

extension FetchedTableViewDataSource: FetchedDataProviderDelegate {
    
    func dataProviderDidUpdate(updates: [FetchedUpdate<Object>]?) {
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

#endif
