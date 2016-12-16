//
//  WebViewController.swift
//  Lily
//
//  Created by Tom Reinhart on 12/16/16.
//  Copyright © 2016 Tom Reinhart. All rights reserved.
//
//
//  WebView.swift
//  OAuthSwift
//
//  Created by Dongri Jin on 2/11/15.
//  Copyright (c) 2015 Dongri Jin. All rights reserved.
//

import OAuthSwift

import UIKit
typealias WebView = UIWebView // WKWebView


class WebViewController: OAuthWebViewController {
    
    var targetURL : NSURL = NSURL()
    let webView : WebView = WebView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.webView.frame = UIScreen.mainScreen().bounds
        self.webView.scalesPageToFit = true
        self.webView.delegate = self
        self.view.addSubview(self.webView)
        loadAddressURL()

    }
    
    override func handle(url: NSURL) {
        targetURL = url
        super.handle(url)
        
        loadAddressURL()
    }
    
    func loadAddressURL() {
        let req = NSURLRequest(URL: targetURL)
        self.webView.loadRequest(req)
    }
}

// MARK: delegate
    extension WebViewController: UIWebViewDelegate {
        func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
            if let url = request.URL, (url.scheme == "oauth-swift"){
                self.dismissWebViewController()
            }
            return true
        }
    }

