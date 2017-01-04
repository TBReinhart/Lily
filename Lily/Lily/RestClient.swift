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


class RestClient {
 
    
    var loader: OAuth2DataLoader?
    fileprivate var alamofireManager: SessionManager?
    
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
    
     func getRequest(url: String) {
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
        
        sessionManager.request(url, method: .get).responseJSON { (response:DataResponse<Any>) in
            
            switch(response.result) {
            case .success(_):
                if response.result.value != nil{
                    print("RESPONSE IN ALAMO:")
                    print(response.result.value ?? "NONE")
                }
                break
                
            case .failure(_):
                print(response.result.error ?? "FAILURE")
                break
                
            }
        }
        
    }

    func postRequest(url: String, parameters: Parameters) {
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
            case .success(_):
                if response.result.value != nil{
                    print(response.result.value ?? "NONE")
                }
                break
                
            case .failure(_):
                print(response.result.error ?? "FAILURE")
                break
                
            }
        }
        
    }
    
    /**
     Delete request
     */
    func deleteRequest(url: String) {
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
            case .success(_):
                if response.result.value != nil{
                    print(response.result.value ?? "NONE")
                }
                break
                
            case .failure(_):
                print(response.result.error ?? "FAILURE")
                break
                
            }
        }
        
    }
    
    func forgetTokens(_ sender: UIButton?) { // or nil params depending on if clicked signed out.
        oauth2.forgetTokens()
    }
    
    
}
