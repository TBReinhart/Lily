//
//  ViewController.swift
//  Lily
//
//  Created by Tom Reinhart on 12/15/16.
//  Copyright © 2016 Tom Reinhart. All rights reserved.
//
import UIKit
import p2_OAuth2
import Alamofire


class ViewController: UIViewController {
    
    fileprivate var alamofireManager: SessionManager?
    
    var loader: OAuth2DataLoader?
    
    var oauth2 = OAuth2CodeGrant(settings: [
        "client_id": "2285YX",
        "client_secret": "60640a94d1b4dcd91602d3efbee6ba87",
        "authorize_uri": "https://www.fitbit.com/oauth2/authorize",
        "token_uri": "https://api.fitbit.com/oauth2/token",
        "response_type": "code",
        "scope": "activity heartrate location nutrition profile settings sleep social weight",
        "redirect_uris": ["lily://oauth/callback"],            // app has registered this scheme
        //"secret_in_body": true,                                      // GitHub does not accept client secret in the Authorization header
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
        
        loader.perform(request: userDataRequest) { response in
            do {
                let json = try response.responseJSON()
                self.didGetUserdata(dict: json, loader: loader)
                debugPrint("RESPONSE")
                debugPrint(json)
                debugPrint(response)
            }
            catch let error {
                debugPrint(error)
                self.didCancelOrFail(error)
            }
        }
    }
    
    
    
    @IBAction func forgetTokens(_ sender: UIButton?) {
        imageView?.isHidden = true
        oauth2.forgetTokens()
        resetButtons()
    }
    
    
    // MARK: - Actions
    
    var userDataRequest: URLRequest {
        let request = URLRequest(url: URL(string: "https://api.fitbit.com/1/user/-/profile.json")!)
        debugPrint(request)
        debugPrint("was request")
        //request.setValue("application/vnd.github.v3+json", forHTTPHeaderField: "Accept")
        return request
    }
    
    func didGetUserdata(dict: [String: Any], loader: OAuth2DataLoader?) {
        DispatchQueue.main.async {
            if let username = dict["name"] as? String {
                self.signInEmbeddedButton?.setTitle(username, for: UIControlState())
            }
            else {
                self.signInEmbeddedButton?.setTitle("(No name found)", for: UIControlState())
            }
            if let imgURL = dict["avatar_url"] as? String, let url = URL(string: imgURL) {
                self.loadAvatar(from: url, with: loader)
            }
            self.forgetButton?.isHidden = false
        }
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
    
    
    // MARK: - Avatar
    
    func loadAvatar(from url: URL, with loader: OAuth2DataLoader?) {
        if let loader = loader {
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
        }
        else {
            alamofireManager?.request(url).validate().responseData() { response in
                if let data = response.result.value {
                    self.imageView?.image = UIImage(data: data)
                    self.imageView?.isHidden = false
                }
                else {
                    print("Failed to load avatar: \(response)")
                }
            }
        }
    }
}
