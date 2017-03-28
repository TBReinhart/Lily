//
//  JournalViewController.swift
//  Lily
//
//  Created by Tom Reinhart on 3/20/17.
//  Copyright © 2017 Tom Reinhart. All rights reserved.
//

import UIKit

class JournalViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var bottomView: UIView!

    @IBOutlet weak var tableView: UITableView!
    let cellReuseIdentifier = "cell"
    let entryDates = ["2/27/17", "1/16/17", "1/5/17"]
    let entryTitles = ["My stomach hurts","I can't remember to take...","Questions for doctor:"]
    var journalEntryDate: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self

        tableView.tableFooterView = UIView()
        let customFrame : CGRect = CGRectMake(0,0,bottomView.frame.width,0.5)
        let customView : UIView = UIView(frame: customFrame)
        customView.backgroundColor = Helpers.UIColorFromRGB(rgbValue: 0x6F6E6F)
        self.bottomView.addSubview(customView)
        tableView.reloadData()

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Unselect the selected row if any
        let selection: IndexPath? = self.tableView.indexPathForSelectedRow
        if selection != nil {
            self.tableView.deselectRow(at: selection!, animated: true)
        }
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
            print("entry background color set")
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
        c.textLabel?.text = "\(entryTitles[indexPath.row])"
        c.textLabel?.font = UIFont(name: "AvenirNext-Regular", size:12);
        c.textLabel?.textColor = Helpers.UIColorFromRGB(rgbValue: 0x6F6E6F)

        c.detailTextLabel?.text = "\(entryDates[indexPath.row])"
        c.detailTextLabel?.font = UIFont(name: "AvenirNext-Regular", size:8);
        c.detailTextLabel?.textColor = Helpers.UIColorFromRGB(rgbValue: 0x6F6E6F)


        return c
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
        performSegue(withIdentifier: "journalEntrySegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "journalEntrySegue") {
            // initialize new view controller and cast it as your view controller
            let viewController = segue.destination as! JournalEntryViewController
            // your new view controller should have property that will store passed value
            viewController.entryDate = self.journalEntryDate
        }
    }

}
