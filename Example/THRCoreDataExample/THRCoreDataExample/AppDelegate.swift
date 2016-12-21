//
//  AppDelegate.swift
//  THRCoreDataExample
//
//  Created by David Yates on 21/12/2016.
//  Copyright © 2016 3Squared Ltd. All rights reserved.
//

import UIKit
import CoreData
import THRCoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var coreDataManager: CoreDataManager!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        guard let tbc = window?.rootViewController as? UITabBarController else { fatalError("Wrong initial view controller") }
        
        coreDataManager = CoreDataManager(modelName: "THRCoreDataExample")
        
        for vc in tbc.viewControllers! {
            if let nc = vc as? UINavigationController, let vc = nc.topViewController as? CoreDataManagerSettable {
                vc.coreDataManager = coreDataManager
            }
            if let vc = vc as? CoreDataManagerSettable {
                vc.coreDataManager = coreDataManager
            }
        }
        
        return true
    }
}
