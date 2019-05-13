//
//  AppDelegate.swift
//  PeakCoreDataExample
//
//  Created by David Yates on 21/12/2016.
//  Copyright © 2016 3Squared Ltd. All rights reserved.
//

import UIKit
import CoreData
import PeakCoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        CoreDataManager.shared.setup { persistentContainer in
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            guard let rootViewController = storyboard.instantiateViewController(withIdentifier: "RootViewController") as? UITabBarController else { fatalError("Wrong view controller type") }
            
            for vc in rootViewController.viewControllers! {
                if let nc = vc as? UINavigationController, let vc = nc.topViewController as? PersistentContainerSettable {
                    vc.persistentContainer = persistentContainer
                }
                if let vc = vc as? PersistentContainerSettable {
                    vc.persistentContainer = persistentContainer
                }
            }

            self.window?.rootViewController = rootViewController
        }
        return true
    }
}

