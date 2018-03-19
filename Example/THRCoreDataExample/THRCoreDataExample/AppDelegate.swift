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
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "THRCoreDataExample")
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        guard let tbc = window?.rootViewController as? UITabBarController else { fatalError("Wrong initial view controller") }

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
