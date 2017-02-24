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
    var persistentContainer: PersistentContainer!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        guard let tbc = window?.rootViewController as? UITabBarController else { fatalError("Wrong initial view controller") }
        
        persistentContainer = PersistentContainer(name: "THRCoreDataExample")
        persistentContainer.loadPersistentStores()

        for vc in tbc.viewControllers! {
            if let nc = vc as? UINavigationController, let vc = nc.topViewController as? PersistentContainerSettable {
                vc.persistentContainer = persistentContainer
            }
            if let vc = vc as? PersistentContainerSettable {
                vc.persistentContainer = persistentContainer
            }
        }
        
        return true
    }
}
