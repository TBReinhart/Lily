//
//  BabyMovementViewController.swift
//  Lily
//
//  Created by Tom Reinhart on 3/1/17.
//  Copyright © 2017 Tom Reinhart. All rights reserved.
//

import UIKit
import SafariServices

class BabyMovementViewController: UIViewController , UITableViewDelegate, UITableViewDataSource {

    var kicksView: KicksSoFarView!
    @IBOutlet weak var tableview: UITableView!
    let cellReuseIdentifier = "cell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
       // loadCustomViewIntoController()
        // Register the table view cell class and its reuse id
        // This view controller itself will provide the delegate methods and row data for the table view.
        tableview.delegate = self
        tableview.dataSource = self
    }

    func loadCustomViewIntoController() {
        let screenSize: CGRect = UIScreen.main.bounds
        kicksView = KicksSoFarView(frame: CGRect(x: 0, y: 0, width: screenSize.width , height: screenSize.height))
        kicksView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        self.view.addSubview(kicksView)
        kicksView.isHidden = false
                
    }
    
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 15
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // create a new cell if needed or reuse an old one
        let c = Bundle.main.loadNibNamed("KickCellView", owner: self, options: nil)?.first as! KickTableViewCell
        c.timeLabel.text = "10:00 AM"
        c.kickLabel.text = "Kick \(indexPath.row)"
        return c
    }
    
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You tapped cell number \(indexPath.row).")
    }
    
    @IBAction func adviceButtonLinkPressed(_ sender: Any) {
        let svc = SFSafariViewController(url: URL(string:"http://americanpregnancy.org/while-pregnant/kick-counts/" )!)
        present(svc, animated: true, completion: nil)
        
    }
    
    

}
