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
    let healthKitReqs = HealthKitRequests()
    let myId = UIDevice.current.identifierForVendor!.uuidString
    var ref: FIRDatabaseReference!

    
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
    
    override func viewDidLoad() {
        
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "Lily_background")!)
    }

    
    @IBAction func loginWithHealthKit(_ sender: Any) {
        if(healthKitReqs.checkAuthorization()) {
            if(healthKitReqs.isHealthDataAvailable()) {
                HUD.show(.progress)
                self.createUserHelper(method: "HealthKit")
                HUD.flash(.success, delay: 0.5)
                self.performSegue(withIdentifier: "loggedInSegue", sender: self)
            }
        }
    }
    
    func createUserHelper(method: String) {
        UserDefaults.standard.setValue(method, forKey: "loginMethod")
        let email = self.myId + "@lilyhealth.me"
        let password = self.myId
        self.createUser(user: self.myId, email: email, password: password)
    }

    
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
                //HUD.show(.progress)
                print("SUCCESS LOGGING IN")
                self.extractUserData(json: json)
                self.createUserHelper(method: "Fitbit")
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
                self.addAttributeToFirebaseUser(attributeName: attribute, value: val)
                if attribute == "height" {
                    val = value as! NSNumber
                    val = "\(val)"
                } else if attribute == "encodedId" {
                    print("ENCODED ID: \(val)")
                    val = value as! String
                    // TODO do something with encodedId
                    continue
                }
                
                LilyCoreData.update(key: attribute, value: val)
            }
        }
        
    }
    
    func addAttributeToFirebaseUser(attributeName: String, value: Any) {
        self.ref = FIRDatabase.database().reference()
        let user = FIRAuth.auth()?.currentUser
        if let uid = user?.uid {
            ref.child("users/\(uid)/\(attributeName)").setValue(value)
        }
    }
    
    

    func createUser(user: String, email: String, password: String) {
        FIRAuth.auth()?.createUser(withEmail: email, password: password) { (user, error) in
            debugPrint("Error: \(error)")
            if error != nil {
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
                self.createOrUpdateFirebaseUserProfile()
            }
        }
    }
    
    func createOrUpdateFirebaseUserProfile() {
        self.ref = FIRDatabase.database().reference()
        let user = FIRAuth.auth()?.currentUser
        // The user's ID, unique to the Firebase project.
        // Do NOT use this value to authenticate with your backend server,
        // if you have one. Use getTokenWithCompletion:completion: instead.
        let email = user?.email ?? "None"
        print("EMAIL: \(email)")
        if let uid = user?.uid {
            //ref.child("users/\(uid)/username").setValue("Tom R.")
            ref.child("users/\(uid)/email").setValue(email)
            ref.child("users/\(uid)/loginMethod").setValue(UserDefaults.standard.string(forKey: "loginMethod") ?? "None")

        }
        //let photoURL = user?.photoURL

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
