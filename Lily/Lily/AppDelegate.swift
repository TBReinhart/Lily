//
//  AppDelegate.swift
//  Lily
//
//  Created by Tom Reinhart on 12/15/16.
//  Copyright © 2016 Tom Reinhart. All rights reserved.
//
import UIKit


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate
{
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        return true
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        if "lily" == url.scheme! {
            if let vc = window?.rootViewController as? ViewController {
                vc.oauth2.handleRedirectURL(url)
                return true
            }
        }
        return false
    }
}
