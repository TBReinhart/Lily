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
import TouchVisualizer
import p2_OAuth2

// only for sys.exit() remove later
import Darwin

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate
{
    var window: UIWindow?
    var storyboard: UIStoryboard?

    var globalTimer: Timer?
    var globalSeconds = 0
    var globalTimerHasStarted = false
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // Set Navigation bar background image
        let navBgImage:UIImage = UIImage(named: "NavigationBar.png")!
        UINavigationBar.appearance().setBackgroundImage(navBgImage, for: .default)
        
        Visualizer.start()
//        Visualizer.stop()

        
        UINavigationBar.appearance().titleTextAttributes = [
            NSForegroundColorAttributeName: UIColor.white
        ]

        //Set navigation bar Back button tint colour
        UINavigationBar.appearance().tintColor = UIColor.white
        FIRApp.configure()
        IQKeyboardManager.sharedManager().enable = true
        FIRDatabase.database().persistenceEnabled = true

        
        let settings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
        application.registerUserNotificationSettings(settings)
        application.registerForRemoteNotifications()
        
        UserDefaults.standard.setValue(false, forKey:"_UIConstraintBasedLayoutLogUnsatisfiable") // disables warnings for views in console

//        
//        forgetTokens(nil)
//        exit(0)
        checkIfUserInFirebase()
        
        

        
        return true
    }
    
    func checkIfUserInFirebase() {
        self.storyboard = UIStoryboard(name: "Main", bundle: Bundle.main);
        let currentUser = FIRAuth.auth()?.currentUser
        print("Current user: \(currentUser?.uid)")
        if currentUser != nil
        {
            // if a firebase user, then need to make sure logged in
            if let loginMethod = UserDefaults.standard.value(forKey: "loginMethod") as? String {
                if loginMethod == "Fitbit" {
                    print("will try and get fitbit tokens")
                    isLoggedInToFitbit()
                } else if loginMethod == "HealthKit" {
                    // check something
                    self.window?.rootViewController = self.storyboard?.instantiateViewController(withIdentifier: "HomeNavigationController");

                } else {
                    return
                }
            }
    

            
        }
    }
    
    func forgetTokens(_ sender: UIButton?) {
        let restClient = RestClient()
        restClient.forgetTokens(nil)
    }

    
    var oauth2 = OAuth2CodeGrant(settings: [
        "client_id": "2285YX",
        "client_secret": "60640a94d1b4dcd91602d3efbee6ba87",
        "authorize_uri": "https://www.fitbit.com/oauth2/authorize",
        "token_uri": "https://api.fitbit.com/oauth2/token",
        "response_type": "code",
        "expires_in": "31536000", // 1 year expiration
        "scope": "activity heartrate location nutrition profile settings sleep social weight",
        "redirect_uris": ["lily://oauth/callback"],            // app has registered this scheme
        "verbose": true,
        ] as OAuth2JSON)
    
    func isLoggedInToFitbit() {
        oauth2.authConfig.authorizeEmbedded = true
         let vcInstance : UIViewController  = ViewController()
        oauth2.authConfig.authorizeContext = vcInstance
        oauth2.logger = OAuth2DebugLogger(.trace)
        print("is logged in to fitbit?")
        oauth2.authorize() { authParameters, error in
            if let params = authParameters {
                print("success in oauth2 appdelegate")
                print("authorized in app delegate")
                print("Authorized! Access token is in `oauth2.accessToken`")
                print("Authorized! Additional parameters: \(params)")
                self.window?.rootViewController = self.storyboard?.instantiateViewController(withIdentifier: "HomeNavigationController");

            }
            else {
                print("Authorization was cancelled or went wrong in appdelegate: \(error)")   // error will not be nil
            }
        }

    }
    
    class func getDelegate() -> AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    // http://www.appcoda.com/push-notification-ios/
    // Step 8
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("DEVICE TOKEN = \(deviceToken)")
        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()

        print(token)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print(error)
    }
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print(userInfo)
    }
    

    /**
     ## Set URL Scheme ##
     Sets URL scheme such that the app can be reopened after performing authentication through fitbit
    */
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        if "lily" == url.scheme! {
            if let vc = window?.rootViewController as? ViewController {
                vc.oauth2.handleRedirectURL(url)
                print("return true from setting url scheme for fitbit")
                return true
            }
        }
        print("false from set delegate url")
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
    
    // MARK: Custom Methods
    
    class func getAppDelegate() -> AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }

    
    func getDocDir() -> String {
        return NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    }
    
}
