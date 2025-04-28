//
//  TableViewDecoratable.swift
//  PeakCoreData
//
//  Created by Zack Brown on 17/03/2025.
//

#if canImport(UIKit)

import UIKit

public protocol TableViewDecoratable: AnyObject {
    associatedtype Header: UITableViewHeaderFooterView
    associatedtype Footer: UITableViewHeaderFooterView
    // Optional
    func identifier(forHeaderIn section: Int) -> String?
    func identifier(forFooterIn section: Int) -> String?
    func heightForHeader(in section: Int) -> CGFloat
    func heightForFooter(in section: Int) -> CGFloat
    func willDisplay(headerView: Header, for section: Int)
    func willDisplay(footerView: Footer, for section: Int)
    func configureHeader(_ header: Header, for section: Int)
    func configureFooter(_ footer: Footer, for section: Int)
}

public extension TableViewDecoratable {
    
    func identifier(forHeaderIn section: Int) -> String? { nil }
    func identifier(forFooterIn section: Int) -> String? { nil }
    func heightForHeader(in section: Int) -> CGFloat { identifier(forHeaderIn: section) != nil ? UITableView.automaticDimension : .leastNormalMagnitude }
    func heightForFooter(in section: Int) -> CGFloat { identifier(forFooterIn: section) != nil ? UITableView.automaticDimension : .leastNormalMagnitude }
    func willDisplay(headerView: UITableViewHeaderFooterView, for section: Int) { }
    func willDisplay(footerView: UITableViewHeaderFooterView, for section: Int) { }
    func configureHeader(_ header: UITableViewHeaderFooterView, for section: Int) { }
    func configureFooter(_ footer: UITableViewHeaderFooterView, for section: Int) { }
}

#endif
