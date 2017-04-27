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
    }

    
    @IBAction func loginWithHealthKit(_ sender: Any) {
        if(healthKitReqs.checkAuthorization()) {
            if(healthKitReqs.isHealthDataAvailable()) {
                HUD.show(.progress)
                self.createUserHelper(method: "HealthKit")

            }
        }
    }
    
    func createUserHelper(method: String) {
        
        UserDefaults.standard.setValue(method, forKey: "loginMethod")
        self.createAnonLogin()
    }
    
    // https://firebase.google.com/docs/auth/ios/anonymous-auth
    func createAnonLogin() {
        FIRAuth.auth()?.signInAnonymously() { (user, error) in
            if error == nil {
                let isAnonymous = user!.isAnonymous  // true
                let uid = user!.uid
                print("anon: \(isAnonymous) and uid: \(uid)")
                Helpers.checkIfDailyLogExists()
                self.createOrUpdateFirebaseUserProfile()
                print("creating anon login")
                DispatchQueue.main.async {
                    HUD.flash(.success, delay: 0.5)
                    self.performSegue(withIdentifier: "loggedInSegue", sender: self)
                }

                
            } else {
                print("error: \(String(describing: error))")
            }

        }
    }
    
    
    
    /**
     ## Embedded Sign In ##
     Use embedded login style using the OAuth2 loader to authorize a user for use in this client
     Embedded Sign In is a permitted style of logging in users according to API docs.
    */
    @IBAction func signInEmbedded(_ sender: UIButton?) {
        HUD.show(.progress)

        self.oauth2Login()

        
    }
    
    
    func oauth2Login() {
        signInEmbeddedButton?.isEnabled = false
        oauth2.authConfig.authorizeEmbedded = true
        oauth2.authConfig.authorizeContext = self
        oauth2.logger = OAuth2DebugLogger(.trace)
        HUD.hide()

        
        oauth2.authorize() { authParameters, error in
            if let params = authParameters {
                print("Authorized in vc! Access token is in `oauth2.accessToken`")
                print("Authorized! Additional parameters: \(params)")
                self.saveFitbitUser()
            }
            else {
                print("Authorization was cancelled in vc or went wrong: \(error)")   // error will not be nil
                self.signInEmbeddedButton?.isEnabled = true
                HUD.flash(.error, delay: 1.0)
            }
        }
        
    }
    
    func saveFitbitUser() {
        let loader = OAuth2DataLoader(oauth2: self.oauth2)
        self.loader = loader
        // loads basic user profile now that logged in
        
        loader.perform(request: userDataRequest) { response in
            do {
                let json = try response.responseJSON()
                self.extractUserData(json: json)
                self.createUserHelper(method: "Fitbit")
                
                
            }
            catch let error {
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
                print("Adding \(attribute):\(val) to firebase")
                self.addAttributeToFirebaseUser(attributeName: attribute, value: val)
                if attribute == "height" {
                    val = value as! NSNumber
                    val = "\(val)"
                } else if attribute == "encodedId" {
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
        print("adding \(attributeName) to firebase")
        if let uid = user?.uid {
            ref.child("users/\(uid)/\(attributeName)").setValue(value)
        }
    }
    
    
    
    func createOrUpdateFirebaseUserProfile() {
        self.ref = FIRDatabase.database().reference()
        let user = FIRAuth.auth()?.currentUser

        let uuid = self.myId
        if let uid = user?.uid {
            ref.child("users/\(uid)/uuid").setValue(uuid)
            ref.child("users/\(uid)/loginMethod").setValue(UserDefaults.standard.string(forKey: "loginMethod") ?? "None")
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
        return request
    }
    /**
     ## Cancel Login ##
     A problem occured with login, so we must reset login.
    */
    func didCancelOrFail(_ error: Error?) {
        DispatchQueue.main.async {
            self.resetButtons()
        }
    }
    

    func resetButtons() {
        signInEmbeddedButton?.setTitle("Sign In (Embedded)", for: UIControlState())
        signInEmbeddedButton?.isEnabled = true
        forgetButton?.isHidden = true
    }
        
}
