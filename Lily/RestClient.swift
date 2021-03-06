//
//  RestClient.swift
//  Lily
//
//  Created by Tom Reinhart on 1/4/17.
//  Copyright © 2017 Tom Reinhart. All rights reserved.
//

import Foundation
import p2_OAuth2
import Alamofire
import SwiftyJSON

class RestClient {
 
    /// Loader for OAuth2 when requesting resources
    var loader: OAuth2DataLoader?
    /// Alamofire manager to do all REST actions
    fileprivate var alamofireManager: SessionManager?
    
    /// Credentials necessary for authenticating with fitbit API
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
    
    /**
     ## Get Request ##
     Uses alamofire and completion handler to request JSON from a given URL
     Will return by completion hander an error or a JSON response
    */
     func getRequest(url: String, completionHandler: @escaping (JSON?, Error?) -> ()) {
        if oauth2.isAuthorizing {
            oauth2.abortAuthorization()
            return
        }
        oauth2.authConfig.authorizeEmbedded = true
        oauth2.authConfig.authorizeContext = self
        
        let sessionManager = SessionManager()
        let retrier = OAuth2RetryHandler(oauth2: oauth2)
        sessionManager.adapter = retrier
        sessionManager.retrier = retrier
        alamofireManager = sessionManager
        
        
        //let manager = Alamofire.Manager(configuration: configuration)
        
        sessionManager.request(url, method: .get).responseJSON { (response:DataResponse<Any>) in
            print("URL Req: \(url)")
            switch(response.result) {
            case .success(let value):
                if response.result.value != nil{
                    let json = JSON(value)
                    sessionManager.session.invalidateAndCancel()
                    completionHandler(json, nil)
                    
                }
                break
                
            case .failure(_):
                sessionManager.session.invalidateAndCancel()
                completionHandler(nil, response.result.error)

                break
                
            }
        }
        
    }
    /**
     ## Post Request ##
     Uses alamofire and completion handler to post JSON to a given URL
     Will return by completion hander an error or a JSON response
     */
    func postRequest(url: String, parameters: Parameters, completionHandler: @escaping (JSON?, Error?) -> ()) {
        if oauth2.isAuthorizing {
            oauth2.abortAuthorization()
            return
        }
        oauth2.authConfig.authorizeEmbedded = true
        oauth2.authConfig.authorizeContext = self
        
        let sessionManager = SessionManager()
        let retrier = OAuth2RetryHandler(oauth2: oauth2)
        sessionManager.adapter = retrier
        sessionManager.retrier = retrier
        alamofireManager = sessionManager
        
        sessionManager.request(url, method: .post, parameters: parameters, encoding: URLEncoding.httpBody, headers: nil).responseJSON { (response:DataResponse<Any>) in
            
            switch(response.result) {
            case .success(let value):
                if response.result.value != nil{
                }
                let json = JSON(value)
                sessionManager.session.invalidateAndCancel()
                completionHandler(json, nil)
                break
                
            case .failure(_):
                sessionManager.session.invalidateAndCancel()
                completionHandler(nil, response.result.error)
                break
                
            }
        }
        
    }
    
    /**
     ## Delete Request ##
     Uses alamofire and completion handler to delete based on a JSON request for a given URL
     Will return by completion hander an error or a JSON response
     */
    func deleteRequest(url: String, completionHandler: @escaping (JSON?, Error?) -> ()) {
        if oauth2.isAuthorizing {
            oauth2.abortAuthorization()
            return
        }
        oauth2.authConfig.authorizeEmbedded = true
        oauth2.authConfig.authorizeContext = self
        
        let sessionManager = SessionManager()
        let retrier = OAuth2RetryHandler(oauth2: oauth2)
        sessionManager.adapter = retrier
        sessionManager.retrier = retrier
        alamofireManager = sessionManager
        
        sessionManager.request(url, method: .delete).responseJSON { (response:DataResponse<Any>) in
            
            switch(response.result) {
            case .success(let value):
                if response.result.value != nil{
                }
                let json = JSON(value)
                sessionManager.session.invalidateAndCancel()
                completionHandler(json, nil)
                break
                
            case .failure(_):
                sessionManager.session.invalidateAndCancel()

                completionHandler(nil, response.result.error)
                break
                
            }
        }
        
    }
    /**
     ## Forget Tokens ##
     This function removes authentication from OAuth2 and requires a user in app to reauthorize the app again
    */
    func forgetTokens(_ sender: UIButton?) { // or nil params depending on if clicked signed out.
        oauth2.forgetTokens()
    }
    
    
}
