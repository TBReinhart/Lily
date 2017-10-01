//
//  JournalViewController.swift
//  Lily
//
//  Created by Tom Reinhart on 3/20/17.
//  Copyright © 2017 Tom Reinhart. All rights reserved.
//

import UIKit
import Firebase
import SwiftyJSON
import DZNEmptyDataSet
import LocalAuthentication
import DynamicBlurView

class JournalViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    @IBOutlet weak var bottomView: UIView!

    @IBOutlet weak var newEntryButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    let cellReuseIdentifier = "cell"
    var entryDates = [String]()
    var journalEntryDate: String!
    var journalKey: String!
    var journalEntry: String!
    var keys = [String]()
    var journalEntries = [String]()
    var isAuthenticated = false
    var userPrefersPassword = true
    var blurView : DynamicBlurView!
        

    override func viewDidLoad() {
        super.viewDidLoad()
        self.blurView = DynamicBlurView(frame: view.bounds)
        self.blurView.alpha = 0.75
        self.blurView.blurRadius = 10

        tableView.delegate = self
        tableView.dataSource = self
        self.tableView.emptyDataSetSource = self;
        self.tableView.emptyDataSetDelegate = self;
        tableView.tableFooterView = UIView()
        let customFrame : CGRect = CGRectMake(0,0,bottomView.frame.width,0.5)
        let customView : UIView = UIView(frame: customFrame)
        customView.backgroundColor = Helpers.UIColorFromRGB(rgbValue: 0x6F6E6F)
        self.bottomView.addSubview(customView)
        self.tableView.tableFooterView = UIView()
        self.authenticateUser()
        
    }
    func resetData() {
        journalEntries = []
        keys = []
        entryDates = []
    }
    
    func authenticateUser() {
        let context = LAContext()
        var error: NSError?
        context.localizedFallbackTitle = ""
        if userPrefersPassword {

            if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
                let reason = "Please authenticate to view your journal!"
                self.blurBackground()
                context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason, reply: { (success: Bool, error: Error?) in
                    DispatchQueue.main.async {
                        // Update UI
                    if success {
                        self.performSuccessfulLogin()
                        
                    } else {
                        var message = ""
                        if let evaluateError = error as NSError? {
                            message = self.errorMessageForLAErrorCode(errorCode: evaluateError.code)
                            //                        self.showAlertViewAfterEvaluatingPolicyWithMessage(message: message)
                            
                            print("Reason for failure: \(message)")
                            
                            if evaluateError.code == LAError.userCancel.rawValue { // user clicked cancel
                                self.navigationController?.popToRootViewController(animated: true)
                                
                            } else if evaluateError.code == LAError.passcodeNotSet.rawValue {
                                // allow the user to skip this screen if no passcode?
                                self.performSuccessfulLogin()
                                
                            } else if evaluateError.code ==  LAError.touchIDLockout.rawValue {
                                self.rejectLogin(title: "Authentication failed.", message: message)
                                
                            } else {
                                self.rejectLogin(title: "Authentication failed.", message: message)
                            }
                            
                            
                        } else { // no error but failure
                            self.navigationController?.popViewController(animated: true)
                        }
                        
                        }
                    }
                })
            } else {
                
                print("cannot proceed with authentication")
                self.rejectLogin(title: "Cannot proceed with authentication.", message: "Please try re-enabling Touch ID")
            }

        } else {
            self.performSuccessfulLogin()
        }
        
    }
    
    func blurBackground() {
        self.view.addSubview(blurView)
    }
    
    func removeBlur() {
        self.blurView.remove()
    }
    
    
    func rejectLogin(title: String, message: String) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Return Home", style: .default) { action in
            // perhaps use action.title here
            self.navigationController?.popViewController(animated: true)
        })
        self.present(ac, animated: true)
        self.isAuthenticated = false
    }
    
    
    func performSuccessfulLogin() {
        print("success")
        removeBlur()
        self.isAuthenticated = true
        self.loadJournalDates()
    }
    
    func showAlertViewAfterEvaluatingPolicyWithMessage(message: String) {
        showAlertWithTitle(title: "Error", message: message)
    }
    
    func showAlertWithTitle(title: String, message: String) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        alertVC.addAction(okAction)
        
        DispatchQueue.main.async {
            self.present(alertVC, animated: true, completion: nil)
        }
    }
    
    func errorMessageForLAErrorCode(errorCode: Int) -> String {
        var message = ""
        
        switch errorCode {
        case LAError.appCancel.rawValue:
            message = "Authentication was cancelled by application"
            
        case LAError.authenticationFailed.rawValue:
            message = "Invalid credentials"
            
        case LAError.invalidContext.rawValue:
            message = "The context is invalid"
            
        case LAError.passcodeNotSet.rawValue:
            message = "Passcode is not set on the device"
            
        case LAError.systemCancel.rawValue:
            message = "Authentication was cancelled by the system"
            
        case LAError.touchIDLockout.rawValue:
            message = "Too many failed attempts.\nPlease re-enable Touch ID"
            
        case LAError.touchIDNotAvailable.rawValue:
            message = "TouchID is not available on the device"
            
        case LAError.userCancel.rawValue:
            message = "User cancellation"
            
        case LAError.userFallback.rawValue:
            message = ""
            
        default:
            message = "Touch ID Error"
        }
        return message
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Unselect the selected row if any
        let selection: IndexPath? = self.tableView.indexPathForSelectedRow
        if selection != nil {
            self.tableView.deselectRow(at: selection!, animated: true)
        }
        if isAuthenticated {
            self.loadJournalDates()
        }
    }
    @IBAction func newEntryButtonPressed(_ sender: Any) {
        print("new entry pressed")
        self.addJournalEntryToFirebase()

    }
    
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return entryDates.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let headerView = view as? UITableViewHeaderFooterView {
            headerView.textLabel?.textAlignment = .center
            headerView.backgroundColor = UIColor.white
            headerView.textLabel?.font = UIFont(name: "AvenirNext-Regular", size:14);
            headerView.textLabel?.textColor = Helpers.UIColorFromRGB(rgbValue: 0x6F6E6F)
        }
    }
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "ENTRIES"
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let c = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let shortenedTitle = self.getTitleForEntry(text: journalEntries[indexPath.row])

        c.textLabel?.text = shortenedTitle
        c.textLabel?.font = UIFont(name: "AvenirNext-Regular", size:12);
        c.textLabel?.textColor = Helpers.UIColorFromRGB(rgbValue: 0x6F6E6F)

        
        let dateLabelText = Helpers.formatDateForUser(dateString: entryDates[indexPath.row])
        c.detailTextLabel?.text = dateLabelText
        c.detailTextLabel?.font = UIFont(name: "AvenirNext-Regular", size:8);
        c.detailTextLabel?.textColor = Helpers.UIColorFromRGB(rgbValue: 0x6F6E6F)
        return c
    }
    

    func loadJournalDates() {
        var ref: FIRDatabaseReference!
        ref = FIRDatabase.database().reference()
        let user = FIRAuth.auth()?.currentUser

        if let uid = user?.uid {
            ref.child("users/\(uid)/journals").observeSingleEvent(of: .value, with: { (snapshot) in
            // don't attach journals to date... unnecessary because they may not make them daily
                var i = 0
                print("Snapshot: \(String(describing: snapshot.value))")
                self.keys = []
                self.journalEntries = []
                self.entryDates = []
                for child in snapshot.children {
                    let snap = child as! FIRDataSnapshot //each child is a snapshot
                    
                    let json = JSON(snap.value!)
                    let journalDate = json["date"].stringValue

                    var entry = ""
                    if let text = json["text"].string {
                        entry = text
                    }
                    let key = json["key"].stringValue
                    self.entryDates.insert(journalDate, at:0)
                    self.journalEntries.insert(entry, at:0)
                    self.keys.insert(key, at: 0)

                    i = i + 1
                }
                print("Loaded entry dates: \(self.entryDates)")
                print("Loaded entries: \(self.journalEntries)")
                self.tableView.reloadData()
            })
        }
       

    }

    
    func getTitleForEntry(text: String) -> String {
        let len = text.characters.count
        var title : String!
        var minTitleLength = 0
        if len == 0 {
            return "No Title"
        } else {
            while minTitleLength < 20 && len > minTitleLength {
                minTitleLength = minTitleLength + 1
            }
        }
        let endIndex = text.index(text.startIndex, offsetBy: minTitleLength)
        title = text.substring(to: endIndex)
        return title
    }

    func addJournalEntryToFirebase() {
        var ref: FIRDatabaseReference!
        ref = FIRDatabase.database().reference()
        let user = FIRAuth.auth()?.currentUser
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy"
        self.journalEntryDate = dateFormatter.string(from: Date())

        if let uid = user?.uid {
            let r = ref.child("users/\(uid)/journals").childByAutoId()
            let key = r.key
            let post = ["date":self.journalEntryDate, "text":nil, "key":key]
            r.setValue(post)
            self.journalKey = key
            print("key autoid: \(key)")
            self.journalEntry = ""
            performSegue(withIdentifier: "journalEntrySegue", sender: self)

        }
    }
    
    
    
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 25))
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "ENTRIES"
        headerView.addSubview(label)
        label.centerXAnchor.constraint(equalTo: headerView.centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: headerView.centerYAnchor).isActive = true
        label.heightAnchor.constraint(equalToConstant: 25).isActive = true
        label.font = UIFont(name: "AvenirNext-Regular", size:14);
        label.textColor = Helpers.UIColorFromRGB(rgbValue: 0x6F6E6F)
        
        let customFrame : CGRect = CGRectMake(0,headerView.frame.height-0.5,headerView.frame.width,0.5)
        let customView : UIView = UIView(frame: customFrame)
        customView.backgroundColor = Helpers.UIColorFromRGB(rgbValue: 0x6F6E6F)
        headerView.addSubview(customView)
        
        return headerView
        
    }
    
    
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You tapped cell number \(indexPath.row).")
        
        self.journalEntryDate = entryDates[indexPath.row]
        self.journalKey = keys[indexPath.row]
        self.journalEntry = journalEntries[indexPath.row]
        performSegue(withIdentifier: "journalEntrySegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "journalEntrySegue") {
            // initialize new view controller and cast it as your view controller
            let viewController = segue.destination as! JournalEntryViewController
            // your new view controller should have property that will store passed value
            viewController.entryDate = self.journalEntryDate
            viewController.journalKey = self.journalKey
            viewController.journalEntry = self.journalEntry
        }
    }
    
    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        let str = "Welcome to Journals"
        let attrs = [NSFontAttributeName: UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)]
        return NSAttributedString(string: str, attributes: attrs)
    }
    
    
    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        let str = "Tap the button below to add your first journal"
        let attrs = [NSFontAttributeName: UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)]
        return NSAttributedString(string: str, attributes: attrs)
    }
    
    
    func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? {
        return UIImage(named: "LilyLoginImage")
    }
    
    
    func buttonTitle(forEmptyDataSet scrollView: UIScrollView, for state: UIControlState) -> NSAttributedString? {
        let str = "Add Journal Entry!"
        let attrs = [NSFontAttributeName: UIFont.preferredFont(forTextStyle: UIFontTextStyle.callout)]
        return NSAttributedString(string: str, attributes: attrs)
    }
    
    
    func emptyDataSet(_ scrollView: UIScrollView, didTap button: UIButton) {
        self.addJournalEntryToFirebase()
    }

}
