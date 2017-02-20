//
//  AppDelegate.swift
//  Lily
//
//  Created by Tom Reinhart on 12/15/16.
//  Copyright © 2016 Tom Reinhart. All rights reserved.
//
import UIKit
import CoreData
import Firebase
import IQKeyboardManagerSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate
{
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // Set Navigation bar background image
        let navBgImage:UIImage = UIImage(named: "NavigationBar.png")!
        UINavigationBar.appearance().setBackgroundImage(navBgImage, for: .default)
        
        
        UINavigationBar.appearance().titleTextAttributes = [
            NSFontAttributeName: UIFont(name: "BlackJack", size: 24)!,
            NSForegroundColorAttributeName: UIColor.white
        ]

        //Set navigation bar Back button tint colour
        UINavigationBar.appearance().tintColor = UIColor.white
        FIRApp.configure()
        IQKeyboardManager.sharedManager().enable = true

        return true
    }


    
    /**
     ## Set URL Scheme ##
     Sets URL scheme such that the app can be reopened after performing authentication through fitbit
    */
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        if "lily" == url.scheme! {
            if let vc = window?.rootViewController as? ViewController {
                vc.oauth2.handleRedirectURL(url)
                return true
            }
        }
        return false
    }
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        print("APP WILL TERMINATE")
        self.saveContext()
    }
    

    
    
    
    /*
     ## Persistent Container ##
     The persistent container for the application. This implementation
     creates and returns a container, having loaded the store for the
     application to it. This property is optional since there are legitimate
     error conditions that could cause the creation of the store to fail.
     */
    lazy var persistentContainer: NSPersistentContainer = {

        let container = NSPersistentContainer(name: "Lily")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    /**
     ## Save Context ##
     Allow the app to save to Core Data
    */
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

    
}
