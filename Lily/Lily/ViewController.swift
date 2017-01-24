//
//  ViewController.swift
//  Lily
//
//  Created by Tom Reinhart on 12/15/16.
//  Copyright © 2016 Tom Reinhart. All rights reserved.
//
import UIKit
import p2_OAuth2
import Firebase
import CoreData
import PKHUD

class ViewController: UIViewController {
    
    
    // When logging in with firebase create a user account based on User's encodedId
    
    
    var loader: OAuth2DataLoader?
    
    
    /// Instance of OAuth2 login credentials
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
    
    /**
     ## Embedded Sign In ##
     Use embedded login style using the OAuth2 loader to authorize a user for use in this client
     Embedded Sign In is a permitted style of logging in users according to API docs.
    */
    @IBAction func signInEmbedded(_ sender: UIButton?) {
        if oauth2.isAuthorizing {
            oauth2.abortAuthorization()
            return
        }
        signInEmbeddedButton?.isEnabled = false
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
                HUD.show(.progress)

                self.extractUserData(json: json)
                DispatchQueue.main.sync {
                    
                    print("Segue")
                    HUD.flash(.success, delay: 0.5)
                    self.performSegue(withIdentifier: "loggedInSegue", sender: self)
                }

            }
            catch let error {
                debugPrint(error)
                self.signInEmbeddedButton?.isEnabled = true
                HUD.flash(.error, delay: 1.0)
                self.didCancelOrFail(error)
            }
        }
    }
    /**
     ## Extract Fitbit Data ##
     
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
                } else if attribute == "encodedId" {
                    print("ENCODED ID: \(val)")
                    val = value as! String
                    let email = val as! String + "@lilyhealth.me"
                    let password = val as! String
                    createUser(user: password, email: email, password: password)
                    continue
                }
                
                LilyCoreData.update(key: attribute, value: val)
            }
        }
        
    }
    

    func createUser(user: String, email: String, password: String) {
        FIRAuth.auth()?.createUser(withEmail: email, password: password) { (user, error) in
            debugPrint("USER: \(user)")
            debugPrint("Error: \(error)")
            if let errCode = FIRAuthErrorCode(rawValue: error!._code) {
                
                switch errCode {
                case .errorCodeInvalidEmail:
                    print("invalid email") // really shouldn't happen at this point since we are creating email
                case .errorCodeEmailAlreadyInUse:
                    print("email in use")
                    self.signIn(user: password, email: email, password: password)
                default:
                    print("Create User Error: \(error)")
                }
            }
        }
    }
    
    func signIn(user: String, email: String, password: String) {
        FIRAuth.auth()?.signIn(withEmail: email, password: password) { (user, error) in
            if error != nil {
                debugPrint("ERROR: \(error)")
            }
            
        }
    }

    /// Another instance of forget tokens, this time done locally
    @IBAction func forgetTokens(_ sender: UIButton?) {
            let restClient = RestClient()
            restClient.forgetTokens(nil)
    }
    
    
    /// request most basic user profile
    var userDataRequest: URLRequest {
        let request = URLRequest(url: URL(string: "https://api.fitbit.com/1/user/-/profile.json")!)
        debugPrint(request)
        return request
    }
    /**
     ## Cancel Login ##
     A problem occured with login, so we must reset login.
    */
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
    
    
}
