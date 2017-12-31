//
//  AppDelegate.swift
//  XMLParsing
//
//  Created by Peter Bohac on 12/25/17.
//  Copyright © 2017 Peter Bohac. All rights reserved.
//

import UIKit
import CoreData
import MapKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var coreDataContainer = NSPersistentContainer(name: "Model")
    var currentMapType = MKMapType.standard

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        Logger.categories.remove(.xmlParsing)

        if NSClassFromString("XCTestCase") != nil {
            return false
        }

        coreDataContainer.loadPersistentStores { storeDescription, error in
            if let error = error {
                Logger.error(category: .view, "\(error)")
            }
            else {
                CoreDataUtils.loadSampleData()
            }
        }

        window = UIWindow()
        window?.rootViewController = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()
        window?.makeKeyAndVisible()

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        guard let navController = window?.rootViewController as? UINavigationController else { return false }
        guard let fileUrl = FileUtils.copyToDocuments(sourceUrl: url) else { return false }

        let fileEntity = GpxFileEntity(context: coreDataContainer.viewContext, name: url.deletingPathExtension().lastPathComponent, filename: fileUrl.lastPathComponent)
        try? coreDataContainer.viewContext.save()

        let vc = TrackListViewController.create(withFile: fileEntity)
        navController.pushViewController(vc, animated: true)
        return true
    }

}

extension AppDelegate {
    static var shared: AppDelegate {
        if Thread.isMainThread {
            return UIApplication.shared.delegate as! AppDelegate
        }
        var delegate: AppDelegate? = nil
        DispatchQueue.main.sync {
            delegate = UIApplication.shared.delegate as? AppDelegate
        }
        return delegate!
    }
}
