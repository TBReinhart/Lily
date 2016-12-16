//
//  ViewController.swift
//  Lily
//
//  Created by Tom Reinhart on 12/15/16.
//  Copyright © 2016 Tom Reinhart. All rights reserved.
//
import OAuthSwift
import UIKit



class ViewController: OAuthViewController {
    // oauth swift object (retain)
    var oauthswift: OAuthSwift?
    
    var currentParameters = [String: String]()
    let formData = Semaphore<FormViewControllerData>()
    
    lazy var internalWebViewController: WebViewController = {
        let controller = WebViewController()
        #if os(OSX)
            controller.view = NSView(frame: NSRect(x:0, y:0, width: 450, height: 500)) // needed if no nib or not loaded from storyboard
        #elseif os(iOS)
            controller.view = UIView(frame: UIScreen.main.bounds) // needed if no nib or not loaded from storyboard
        #endif
        controller.delegate = self
        controller.viewDidLoad() // allow WebViewController to use this ViewController as parent to be presented
        return controller
    }()
    
}

            
extension ViewController: OAuthWebViewControllerDelegate {
    #if os(iOS) || os(tvOS)
    
    func oauthWebViewControllerDidPresent() {
        
    }
    func oauthWebViewControllerDidDismiss() {
        
    }
    #endif
    
    func oauthWebViewControllerWillAppear() {
        
    }
    func oauthWebViewControllerDidAppear() {
        
    }
    func oauthWebViewControllerWillDisappear() {
        
    }
    func oauthWebViewControllerDidDisappear() {
        // Ensure all listeners are removed if presented web view close
        oauthswift?.cancel()
    }
}

extension ViewController {
    
    // MARK: - do authentification
    func doAuthService(service: String) {
        
        // Check parameters
        guard var parameters = services[service] else {
            showAlertView(title: "Miss configuration", message: "\(service) not configured")
            return
        }
        self.currentParameters = parameters
        
        // Ask to user by showing form from storyboards
        self.formData.data = nil
        Queue.main.async { [unowned self] in
            self.performSegue(withIdentifier: Storyboards.Main.FormSegue, sender: self)
            // see prepare for segue
        }
        // Wait for result
        guard let data = formData.waitData() else {
            // Cancel
            return
        }
        
        parameters["consumerKey"] = data.key
        parameters["consumerSecret"] = data.secret
        
        if Services.parametersEmpty(parameters) { // no value to set
            let message = "\(service) seems to have not weel configured. \nPlease fill consumer key and secret into configuration file \(self.confPath)"
            print(message)
            Queue.main.async { [unowned self] in
                self.showAlertView(title: "Key and secret must not be empty", message: message)
            }
        }
        
        parameters["name"] = service
        
        switch service {
        case "Fitbit2":
            doOAuthFitbit2(parameters)
    }
    
        
    func doOAuthFitbit2(_ serviceParameters: [String:String]) {
        let oauthswift = OAuth2Swift(
            consumerKey:    serviceParameters["consumerKey"]!,
            consumerSecret: serviceParameters["consumerSecret"]!,
            authorizeUrl:   "https://www.fitbit.com/oauth2/authorize",
            accessTokenUrl: "https://api.fitbit.com/oauth2/token",
            responseType:   "code"
        )
        oauthswift.accessTokenBasicAuthentification = true
        
        self.oauthswift = oauthswift
        oauthswift.authorizeURLHandler = getURLHandler()
        let state = generateState(withLength: 20)
        let _ = oauthswift.authorize(
            withCallbackURL: URL(string: "oauth-swift://oauth-callback/fitbit2")!, scope: "profile weight", state: state,
            success: { credential, response, parameters in
                self.showTokenAlert(name: serviceParameters["name"], credential: credential)
                self.testFitbit2(oauthswift)
        },
            failure: { error in
                print(error.description)
        }
        )
    }
    func testFitbit2(_ oauthswift: OAuth2Swift) {
        let _ = oauthswift.client.get(
            "https://api.fitbit.com/1/user/-/profile.json",
            parameters: [:],
            success: { response in
                let jsonDict = try? response.jsonObject()
                print(jsonDict as Any)
        },
            failure: { error in
                print(error.description)
        }
        )
    }
    
let services = Services()
let DocumentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
let FileManager: FileManager = Foundation.FileManager.default

extension ViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load config from files
        initConf()
        
        // init now web view handler
        let _ = internalWebViewController.webView
        
        #if os(iOS)
            self.navigationItem.title = "OAuth"
            let tableView: UITableView = UITableView(frame: self.view.bounds, style: .plain)
            tableView.delegate = self
            tableView.dataSource = self
            self.view.addSubview(tableView)
        #endif
    }
    
    // MARK: utility methods
    
    var confPath: String {
        let appPath = "\(DocumentDirectory)/.oauth/"
        if !FileManager.fileExists(atPath: appPath) {
            do {
                try FileManager.createDirectory(atPath: appPath, withIntermediateDirectories: false, attributes: nil)
            }catch {
                print("Failed to create \(appPath)")
            }
        }
        return "\(appPath)Services.plist"
    }
    
    func initConf() {
        initConfOld()
        print("Load configuration from \n\(self.confPath)")
        
        // Load config from model file
        if let path = Bundle.main.path(forResource: "Services", ofType: "plist") {
            services.loadFromFile(path)
            
            if !FileManager.fileExists(atPath: confPath) {
                do {
                    try FileManager.copyItem(atPath: path, toPath: confPath)
                }catch {
                    print("Failed to copy empty conf to\(confPath)")
                }
            }
        }
        services.loadFromFile(confPath)
    }
    
    func initConfOld() { // TODO Must be removed later
        services["Fitbit"] = Fitbit

    
    func snapshot() -> Data {
        #if os(iOS)
            UIGraphicsBeginImageContext(self.view.frame.size)
            self.view.layer.render(in: UIGraphicsGetCurrentContext()!)
            let fullScreenshot = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            UIImageWriteToSavedPhotosAlbum(fullScreenshot!, nil, nil, nil)
            return UIImageJPEGRepresentation(fullScreenshot!, 0.5)!
        #elseif os(OSX)
            let rep: NSBitmapImageRep = self.view.bitmapImageRepForCachingDisplay(in: self.view.bounds)!
            self.view.cacheDisplay(in: self.view.bounds, to:rep)
            return rep.tiffRepresentation!
        #endif
    }
    
    func showAlertView(title: String, message: String) {
            let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)

    }
    
    func showTokenAlert(name: String?, credential: OAuthSwiftCredential) {
        var message = "oauth_token:\(credential.oauthToken)"
        if !credential.oauthTokenSecret.isEmpty {
            message += "\n\noauth_token_secret:\(credential.oauthTokenSecret)"
        }
        self.showAlertView(title: name ?? "Service", message: message)
        
        if let service = name {
            services.updateService(service, dico: ["authentified":"1"])
            // TODO refresh graphic
        }
    }
    
    // MARK: handler
    
    func getURLHandler() -> OAuthSwiftURLHandlerType {
        guard let type = self.formData.data?.handlerType else {
            return OAuthSwiftOpenURLExternally.sharedInstance
        }
        switch type {
        case .external :
            return OAuthSwiftOpenURLExternally.sharedInstance
        case .`internal`:
            if internalWebViewController.parent == nil {
                self.addChildViewController(internalWebViewController)
            }
            return internalWebViewController
        case .safari:
                if #available(iOS 9.0, *) {
                    let handler = SafariURLHandler(viewController: self, oauthSwift: self.oauthswift!)
                    handler.presentCompletion = {
                        print("Safari presented")
                    }
                    handler.dismissCompletion = {
                        print("Safari dismissed")
                    }
                    return handler
                }
            return OAuthSwiftOpenURLExternally.sharedInstance
        }
        

    }
    //(I)
    //let webViewController: WebViewController = internalWebViewController
    //(S)
    //var urlForWebView:?URL = nil
    
    
    override func prepare(for segue: OAuthStoryboardSegue, sender: Any?) {
        if segue.identifier == Storyboards.Main.FormSegue {
            #if os(OSX)
                let controller = segue.destinationController as? FormViewController
            #else
                let controller = segue.destination as? FormViewController
            #endif
            // Fill the controller
            if let controller = controller {
                controller.delegate = self
            }
        }
        
        super.prepare(for: segue, sender: sender)
    }
    
}

public typealias Queue = DispatchQueue
// MARK: - Table

    extension ViewController: UITableViewDelegate, UITableViewDataSource {
        // MARK: UITableViewDataSource
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return services.keys.count
        }
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "Cell")
            let service = services.keys[indexPath.row]
            cell.textLabel?.text = service
            
            if let parameters = services[service] , Services.parametersEmpty(parameters) {
                cell.textLabel?.textColor = UIColor.red
            }
            if let parameters = services[service], let authentified = parameters["authentified"], authentified == "1" {
                cell.textLabel?.textColor = UIColor.green
            }
            return cell
        }
        
        // MARK: UITableViewDelegate
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            let service: String = services.keys[indexPath.row]
            
            DispatchQueue.global(qos: .background).async {
                self.doAuthService(service: service)
            }
            tableView.deselectRow(at: indexPath, animated:true)
        }
    }

    
    struct FormViewControllerData {
        var key: String
        var secret: String
        var handlerType: URLHandlerType
    }
    
    extension ViewController: FormViewControllerDelegate {
        
        var key: String? { return self.currentParameters["consumerKey"] }
        var secret: String? {return self.currentParameters["consumerSecret"] }
        
        func didValidate(key: String?, secret: String?, handlerType: URLHandlerType) {
            self.dismissForm()
            
            self.formData.publish(data: FormViewControllerData(key: key ?? "", secret: secret ?? "", handlerType: handlerType))
        }
        
        func didCancel() {
            self.dismissForm()
            
            self.formData.cancel()
        }
        
        func dismissForm() {
            #if os(iOS)
                /*self.dismissViewControllerAnimated(true) { // without animation controller
                 print("form dismissed")
                 }*/
                let _ = self.navigationController?.popViewController(animated: true)
            #endif
        }
    }
    
    // Little utility class to wait on data
    class Semaphore<T> {
        let segueSemaphore = DispatchSemaphore(value: 0)
        var data: T?
        
        func waitData(timeout: DispatchTime? = nil) -> T? {
            if let timeout = timeout {
                let _ = segueSemaphore.wait(timeout: timeout) // wait user
            } else {
                segueSemaphore.wait()
            }
            return data
        }
        
        func publish(data: T) {
            self.data = data
            segueSemaphore.signal()
        }
        
        func cancel() {
            segueSemaphore.signal()
        }
}



