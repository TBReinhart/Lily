//
//  ViewController.swift
//  Lily
//
//  Created by Tom Reinhart on 12/15/16.
//  Copyright © 2016 Tom Reinhart. All rights reserved.
//
import UIKit
import p2_OAuth2
import CoreData

class ViewController: UIViewController {
    
    var loader: OAuth2DataLoader?
    
    
    
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
    
    @IBOutlet var imageView: UIImageView?
    @IBOutlet var signInEmbeddedButton: UIButton?
    @IBOutlet var forgetButton: UIButton?
    
    
    @IBAction func signInEmbedded(_ sender: UIButton?) {
        if oauth2.isAuthorizing {
            oauth2.abortAuthorization()
            return
        }
        sender?.setTitle("Authorizing...", for: UIControlState.normal)
        oauth2.authConfig.authorizeEmbedded = true
        oauth2.authConfig.authorizeContext = self
        let loader = OAuth2DataLoader(oauth2: oauth2)
        self.loader = loader
        // loads basic user profile now that logged in
        loader.perform(request: userDataRequest) { response in
            do {
                let json = try response.responseJSON()
                debugPrint("RESPONSE in json")
                debugPrint(json)

                self.extractUserData(json: json)

                self.performSegue(withIdentifier: "loggedInSegue", sender: self)

            }
            catch let error {
                debugPrint(error)
                self.didCancelOrFail(error)
            }
        }
    }
    /**
     Extract and Save user data from their initial login. Save to Core Data
     */
    func extractUserData(json: [String: Any]) {
        let attributes = FitbitRequests.profileAttributes

        for attribute in attributes {
            if let value = (json["user"] as? [String : Any])?[attribute] {
                var val = value
                if attribute == "height" {
                    val = value as! NSNumber
                    val = "\(val)"
                }
                LilyCoreData.update(key: attribute, value: val)
            }
        }
        
    }
    

    
    @IBAction func forgetTokens(_ sender: UIButton?) {
            let FBReqs = FitbitRequests()
            FBReqs.forgetTokens(nil)
    }
    
    
    // request most basic user profile
    var userDataRequest: URLRequest {
        let request = URLRequest(url: URL(string: "https://api.fitbit.com/1/user/-/profile.json")!)
        debugPrint(request)
        return request
    }
    
    func didCancelOrFail(_ error: Error?) {
        DispatchQueue.main.async {
            if let error = error {
                print("Authorization went wrong: \(error)")
            }
            self.resetButtons()
        }
    }
    

    func resetButtons() {
        signInEmbeddedButton?.setTitle("Sign In (Embedded)", for: UIControlState())
        signInEmbeddedButton?.isEnabled = true
        forgetButton?.isHidden = true
    }
    
    
    // Load avatar from url
    func loadAvatar(from url: URL, with loader: OAuth2DataLoader?) {
        if let loader = loader {
            print("Loader=loader")
            loader.perform(request: URLRequest(url: url)) { response in
                do {
                    let data = try response.responseData()
                    DispatchQueue.main.async {
                        self.imageView?.image = UIImage(data: data)
                        self.imageView?.isHidden = false
                    }
                }
                catch let error {
                    print("Failed to load avatar: \(error)")
                }
            }
        } else {
            debugPrint("ERROR LOADER NOT USED. ABORT")
        }
    }
}
