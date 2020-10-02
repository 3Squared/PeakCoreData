//
//  SceneDelegate.swift
//  PeakCoreDataExample
//
//  Created by David Yates on 29/09/2020.
//

import UIKit
import CoreData
import PeakCoreData

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "PeakCoreDataExample")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }()
        
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }
        guard let tbc = window?.rootViewController as? UITabBarController else { fatalError("Wrong initial view controller") }
        
        tbc.viewControllers?.forEach { vc in
            if let nc = vc as? UINavigationController, let vc = nc.topViewController as? PersistentContainerSettable {
                vc.persistentContainer = persistentContainer
            }
            if let vc = vc as? PersistentContainerSettable {
                vc.persistentContainer = persistentContainer
            }
        }
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        saveContext()
    }
    
    func saveContext () {
        let context = persistentContainer.viewContext
        guard context.hasChanges else { return }

        do {
            try context.save()
        } catch {
            fatalError("Error Saving Context: \(error)")
        }
    }
}
