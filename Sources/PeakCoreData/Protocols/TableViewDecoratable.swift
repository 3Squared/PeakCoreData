//
//  TableViewDecoratable.swift
//  PeakCoreData
//
//  Created by Zack Brown on 17/03/2025.
//

#if canImport(UIKit)

import UIKit

public protocol TableViewDecoratable: AnyObject {
    
    // Optional
    func identifier(forHeaderIn section: Int) -> String?
    func identifier(forFooterIn section: Int) -> String?
    func heightForHeader(in section: Int) -> CGFloat
    func heightForFooter(in section: Int) -> CGFloat
    func willDisplay(headerView: UIView, for section: Int)
    func willDisplay(footerView: UIView, for section: Int)
    func configure(header view: UIView, for section: Int)
    func configure(footer view: UIView, for section: Int)
}

public extension TableViewDecoratable {
    
    func identifier(forHeaderIn section: Int) -> String? { nil }
    func identifier(forFooterIn section: Int) -> String? { nil }
    func heightForHeader(in section: Int) -> CGFloat { .leastNormalMagnitude }
    func heightForFooter(in section: Int) -> CGFloat { .leastNormalMagnitude }
    func willDisplay(headerView: UIView, for section: Int) { }
    func willDisplay(footerView: UIView, for section: Int) { }
    func configure(header view: UIView, for section: Int) { }
    func configure(footer view: UIView, for section: Int) { }
}

#endif
