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

class JournalViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
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

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self

        tableView.tableFooterView = UIView()
        let customFrame : CGRect = CGRectMake(0,0,bottomView.frame.width,0.5)
        let customView : UIView = UIView(frame: customFrame)
        customView.backgroundColor = Helpers.UIColorFromRGB(rgbValue: 0x6F6E6F)
        self.bottomView.addSubview(customView)
        
        self.loadJournalDates()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Unselect the selected row if any
        let selection: IndexPath? = self.tableView.indexPathForSelectedRow
        if selection != nil {
            self.tableView.deselectRow(at: selection!, animated: true)
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
        print("Shortened title")
        print(shortenedTitle)
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
                for child in snapshot.children {
                    let snap = child as! FIRDataSnapshot //each child is a snapshot
                    
                    let json = JSON(snap.value)
                    print("json: \(json)")
                    let journalDate = json["date"].stringValue
                    if journalDate.characters.count == 0 {
                        continue
                    }
                    var entry = ""
                    if let text = json["text"].string {
                        entry = text
                    }
                    let key = json["key"].stringValue
                    self.entryDates.append(journalDate)
                    self.journalEntries.append(entry)
                    self.keys.append(key)

                    i = i + 1
                }
                print(self.entryDates)
                print(self.journalEntries)
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

}
