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
import SwiftyJSON



// only for sys.exit() remove later
import Darwin

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate
{
    var window: UIWindow?
    var storyboard: UIStoryboard?
    var verifyWeight = false
    var dayBar = false
    var weekBar = false
        var currentActivityType = "minutesVeryActive"

    var sedentary = "0"
    var lightly = "0"
    var fairly = "0"
    var very = "0"
    var water1 = ""
    var totalCups = 0.0
    
     var heart1 = ""
     var heart2 = ""
    var heartNum = 0.0
    var heartOver = 0.0
    
    var miserable = 0
    var likeLaughing = 0
    var angry = 0
    var frustrated = 0
    var likeCrying = 0
    var irate = 0
    var sad = 0
    var scared = 0
    var overwhelmed = 0
    var excited = 0
    var happy = 0
    var nervous = 0
    var logged = 0.0
    var redCount = 0.0
            var yellowCount = 0.0
            var blueCount = 0.0
            var greenCount = 0.0
    var sedTime = 0
    var lightTime = 0
    var fairTime = 0
    var veryTime = 0

    var fbreqs = FitbitRequests()
        var today = Date()
var emotionsArray = [Int]()
var anger = ""
var sadness = ""
var happiness = ""
var anxiety = ""

var laughE = false
var forwardE = false
var anxiousE = false
var scaredE = false
var overwhelmedE = false
var sleepE = false
var miserableE = false
var cryE = false



var pdf = PDFGenerator()


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    
FIRApp.configure()
        IQKeyboardManager.sharedManager().enable = true
        FIRDatabase.database().persistenceEnabled = true
        checkIfUserInFirebase()

    
      

    


        
//        self.fbreqs.getUserProfile() { json, err in
//         
//            if json != nil {
//                for (key, value) in json! {
//                    print(key)
//                   // print(value)
//                   let str1 = value.description
//                   print("lkl")
//                   print(str1)
//                    
//                  // self.setEmotionCell(emotion: key, selected: value.boolValue)
//                  // create array to hold bool values then connect each one to emotion separately through ifs (array[num]) to access...
//                }
//
//            }
//
//            
//            let dob = json?["dateOfBirth"]
//            print("uhuh")
//            print(dob)
//                
//}
        
        
        
        
        
        
        
        
        // Set Navigation bar background image
        let navBgImage:UIImage = UIImage(named: "NavigationBar.png")!
        UINavigationBar.appearance().setBackgroundImage(navBgImage, for: .default)
        
        Visualizer.start()
        
        UINavigationBar.appearance().titleTextAttributes = [
            NSForegroundColorAttributeName: UIColor.white
        ]

        //Set navigation bar Back button tint colour
        UINavigationBar.appearance().tintColor = UIColor.white


        
        let settings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
        application.registerUserNotificationSettings(settings)
        application.registerForRemoteNotifications()
        
        UserDefaults.standard.setValue(false, forKey:"_UIConstraintBasedLayoutLogUnsatisfiable") // disables warnings for views in console
//
//        self.logout()
//        exit(0)
        
        
        
        

        
        return true
    }
    
    func logout() {
        // Delete User credential from NSUserDefaults and other data related to user
        let restClient = RestClient()
        restClient.forgetTokens(nil)
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        UserDefaults.standard.synchronize()
        
        let appDelegateTemp: AppDelegate? = (UIApplication.shared.delegate as! AppDelegate)
        let rootController: UIViewController? = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "LoginViewController")
        let navigation = UINavigationController(rootViewController: rootController!)
        appDelegateTemp?.window?.rootViewController = navigation
    }
    
    
    
    func checkIfUserInFirebase() {
        self.storyboard = UIStoryboard(name: "Main", bundle: Bundle.main);
        let currentUser = FIRAuth.auth()?.currentUser
        print("Current user: \(currentUser?.uid)")
        if currentUser != nil {
            // if a firebase user, then need to make sure logged in
            if let loginMethod = UserDefaults.standard.value(forKey: "loginMethod") as? String {
                print("login method")
                if loginMethod == "Fitbit" {
                    print("will try and get fitbit tokens")
                    isLoggedInToFitbit()
                } else if loginMethod == "HealthKit" {
                    // check something
                    self.window?.rootViewController = self.storyboard?.instantiateViewController(withIdentifier: "HomeNavigationController");

                } else {
                    print("other loginMethod")
                }
            } else {
                print("No login method saved")
                self.goToLogin()
            }
            
        } else { // they aren't authenticated
            self.goToLogin()
            
        }
    }
    
    func goToLogin() {
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let loginVC = mainStoryboard.instantiateViewController(withIdentifier: "LoginViewController") as! ViewController
        let nav = UINavigationController(rootViewController: loginVC)
        window?.rootViewController = nav
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
        let vc = self.window?.rootViewController
        oauth2.authConfig.authorizeContext = vc

        oauth2.logger = OAuth2DebugLogger(.trace)
        print("is logged in to fitbit?")

        oauth2.authorize() { authParameters, error in
            
            print("Error: \(String(describing: error))")
            
            if let params = authParameters {
                print("success in oauth2 appdelegate")
                print("authorized in app delegate")
                print("Authorized! Access token is in `oauth2.accessToken`")
                print("Authorized! Additional parameters: \(params)")
                self.window?.rootViewController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateInitialViewController()
                        var weeklyEmotions: JSON = [:]
        
        let dateRange = Helpers.get7DayRangeInts(weeksAgo: 0)
        for i in  dateRange.0..<dateRange.1 + 1 {

            Helpers.loadDailyLogFromFirebase(key: "emotions", daysAgo: i) { json, error in
                if json != nil {
                print("asds")
                print(json)
                    weeklyEmotions[String(i)] = json
                    self.logged += 1
            if weeklyEmotions[String(i)]["frustrated"].boolValue {
                //self.redCount += 1
            }
            
            if weeklyEmotions[String(i)]["angry"].boolValue {
                self.redCount += 1
            }
            
            if weeklyEmotions[String(i)]["irate"].boolValue {
               // self.redCount += 1
            }
            
            if weeklyEmotions[String(i)]["overwhelmed"].boolValue {
            self.overwhelmedE = true
                self.yellowCount += 1
            }
            
            if weeklyEmotions[String(i)]["nervous"].boolValue {
            self.anxiousE = true
                //self.yellowCount += 1
            }
            
            if weeklyEmotions[String(i)]["scared"].boolValue {
            self.scaredE = true
               // self.yellowCount += 1
            }
            
            if weeklyEmotions[String(i)]["sad"].boolValue {
            self.miserableE = true
                self.blueCount += 1
            }
            
            
            if weeklyEmotions[String(i)]["like crying"].boolValue {
            self.cryE = true
               // self.blueCount += 1
            }
            
            if weeklyEmotions[String(i)]["miserable"].boolValue {
            self.miserableE = true
               // self.blueCount += 1
            }
            
            if weeklyEmotions[String(i)]["happy"].boolValue {
                self.greenCount += 1
            }
            
            if weeklyEmotions[String(i)]["excited"].boolValue {
            self.forwardE = true
               // self.greenCount += 1
            }
            
            if weeklyEmotions[String(i)]["like laughing"].boolValue {
            self.laughE = true
               // self.greenCount += 1
            }

                } 

            }
        
        
    
                }

    
    
     
 
    

//
//let num11 = self.redCount
//let num12 = self.greenCount
//let num13 = self.blueCount
//let num14 = self.yellowCount
//print(self.blueCount)
//    print("eve")
//    print(num11)
//    print(num12)
//    print(num13)
//    print(num14)
//self.anger = "\(num11)%"
//self.sadness = "\(num12)%"
//self.happiness = "\(num13)%"
//self.anxiety = "\(num14)%"
    
    
      let endDate = Helpers.getDateNWeeksAgo(weeksAgo: 0).dateString
        let past1 = Helpers.getDateNWeeksAgo(weeksAgo: 0)
        let date1 = past1.date

        
        self.fbreqs.getHeartRateTimeSeriesFromPeriod(date: endDate, period: "7d") { heartRates, err in
            if let hrs = heartRates {
                var i = 0
                for hr in hrs {
                    let rest = Double(hr.restingHeartRate)
                    self.heartNum += rest
                    if (hr.maximumBPM > 204) {
                    self.heartOver += Double(hr.maximumBPM)
                    }
                  

                    i += 1
                }
                self.heartNum = self.heartNum/7
                self.heart1 = "\(self.heartNum)"
                self.heart2 = "\(self.heartOver)"
            }
        }
        

    
        
        let past = Helpers.getDateNWeeksAgo(weeksAgo: 0)
        let date = past.date
        let labelRange = Helpers.getShortDateRangeString(date: date)
        let dateString = past.dateString
        
        self.fbreqs.getWaterLastWeek(date: dateString) { waters, error in
            if waters != nil {
                var i = 0
                for water in waters! {
                    let cupsConsumed = water.cupsConsumed
                    self.totalCups += cupsConsumed
                    i += 1
                    print("check")
                    print(self.totalCups)
                    print(cupsConsumed)
                    print(water)
                }
                 print("this")
        print(self.totalCups)
        self.totalCups = self.totalCups/7
        self.totalCups = (self.totalCups * 100).rounded() / 100
        self.water1 = "\(self.totalCups)"

            }
        }
        
        
        

    let acitivityType = "minutesSedentary"
    let acitivityType1 = "minutesLightlyActive"
    let acitivityType2 = "minutesFairlyActive"
    let acitivityType3 = "minutesVeryActive"

        self.fbreqs.getActivityTimeSeriesFromPeriod(resourcePath: "\(acitivityType)", date: endDate, period: "7d") { activities, err in
            var i = 0
            for activity in activities {
            let num1 = activity.sedentaryMinutes
            self.sedTime += num1

                i += 1

            }
            self.sedTime = self.sedTime/7
            let formattedTime = Helpers.minutesToHoursMinutes(minutes: self.sedTime)

              self.sedentary = "\(formattedTime.0)h \(formattedTime.1)m"

        }
        self.fbreqs.getActivityTimeSeriesFromPeriod(resourcePath: "\(acitivityType1)", date: endDate, period: "7d") { activities, err in
            var i = 0
            for activity in activities {
            let num1 = activity.lightlyActiveMinutes
            self.lightTime += num1

                i += 1

            }
            self.lightTime = self.lightTime/7
            let formattedTime = Helpers.minutesToHoursMinutes(minutes: self.lightTime)

              self.lightly = "\(formattedTime.0)h \(formattedTime.1)m"

        }
        self.fbreqs.getActivityTimeSeriesFromPeriod(resourcePath: "\(acitivityType3)", date: endDate, period: "7d") { activities, err in
            var i = 0
            for activity in activities {
            let num1 = activity.veryActiveMinutes
            self.veryTime += num1

                i += 1

            }
            self.veryTime = self.veryTime/7
            let formattedTime = Helpers.minutesToHoursMinutes(minutes: self.veryTime)

              self.very = "\(formattedTime.0)h \(formattedTime.1)m"

        }
        self.fbreqs.getActivityTimeSeriesFromPeriod(resourcePath: "\(acitivityType2)", date: endDate, period: "7d") { activities, err in
            var i = 0
            for activity in activities {
            let num1 = activity.fairlyActiveMinutes
            self.fairTime += num1

                i += 1

            }
            self.fairTime = self.fairTime/7
            let formattedTime = Helpers.minutesToHoursMinutes(minutes: self.fairTime)

              self.fairly = "\(formattedTime.0)h \(formattedTime.1)m"

        }
                
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
        print("URL SCHEME: \(url.scheme!)")
        
        if "lily" == url.scheme! {
            oauth2.handleRedirectURL(url)

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
    
    // MARK: Custom Methods
    
    class func getAppDelegate() -> AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }

    
    func getDocDir() -> String {
        return NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    }
    
}
