//
//  PeakCoreData+Aliases.swift
//  PeakCoreData-iOS
//
//  Created by Zack Brown on 02/07/2019.
//  Copyright © 2019 3Squared Ltd. All rights reserved.
//

#if os(iOS) || os(tvOS)

import UIKit

public typealias PeakView = UIView

#else

import AppKit

public typealias PeakView = NSView

#endif

